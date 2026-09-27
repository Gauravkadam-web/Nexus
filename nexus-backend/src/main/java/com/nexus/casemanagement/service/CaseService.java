package com.nexus.casemanagement.service;

import com.nexus.auth.security.UserPrincipal;
import com.nexus.ai.event.CaseCreatedEvent;
import com.nexus.casemanagement.dto.*;
import com.nexus.casemanagement.entity.*;
import com.nexus.casemanagement.repository.CaseAssignmentRepository;
import com.nexus.casemanagement.repository.CaseRepository;
import com.nexus.casemanagement.statemachine.CaseLifecycleService;
import com.nexus.common.exception.BadRequestException;
import com.nexus.common.exception.ResourceNotFoundException;
import com.nexus.organization.entity.Category;
import com.nexus.organization.entity.Team;
import com.nexus.organization.repository.CategoryRepository;
import com.nexus.organization.repository.TeamRepository;
import com.nexus.user.entity.User;
import com.nexus.user.repository.UserRepository;
import com.nexus.sla.service.SlaService;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Set;
import java.util.UUID;

@Service
public class CaseService {

    private final CaseRepository caseRepository;
    private final CaseAssignmentRepository caseAssignmentRepository;
    private final CategoryRepository categoryRepository;
    private final TeamRepository teamRepository;
    private final UserRepository userRepository;
    private final CaseLifecycleService lifecycleService;
    private final ApplicationEventPublisher eventPublisher;
    private final SlaService slaService;

    public CaseService(CaseRepository caseRepository,
                       CaseAssignmentRepository caseAssignmentRepository,
                       CategoryRepository categoryRepository,
                       TeamRepository teamRepository,
                       UserRepository userRepository,
                       CaseLifecycleService lifecycleService,
                       ApplicationEventPublisher eventPublisher,
                       SlaService slaService) {
        this.caseRepository = caseRepository;
        this.caseAssignmentRepository = caseAssignmentRepository;
        this.categoryRepository = categoryRepository;
        this.teamRepository = teamRepository;
        this.userRepository = userRepository;
        this.lifecycleService = lifecycleService;
        this.eventPublisher = eventPublisher;
        this.slaService = slaService;
    }

    @Transactional
    public CaseDetailResponse createCase(CreateCaseRequest request, UserPrincipal principal) {
        User requester = userRepository.findById(principal.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Requester user not found"));

        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new ResourceNotFoundException("Category not found with ID: " + request.getCategoryId()));

        Category subcategory = null;
        if (request.getSubcategoryId() != null) {
            subcategory = categoryRepository.findById(request.getSubcategoryId())
                    .orElseThrow(() -> new ResourceNotFoundException("Subcategory not found with ID: " + request.getSubcategoryId()));
        }

        Case newCase = new Case();
        newCase.setCaseNumber(generateCaseNumber());
        newCase.setTitle(request.getTitle());
        newCase.setDescription(request.getDescription());
        newCase.setCategory(category);
        newCase.setSubcategory(subcategory);
        newCase.setSeverity(request.getSeverity() != null ? request.getSeverity() : Severity.MEDIUM);
        newCase.setPriority(request.getPriority() != null ? request.getPriority() : Priority.MEDIUM);
        newCase.setStatus(CaseStatus.REPORTED);
        newCase.setRequester(requester);
        newCase.setLocation(request.getLocation());

        // Default routing to category's team if available
        if (category.getDefaultTeam() != null) {
            newCase.setAssignedTeam(category.getDefaultTeam());
        }

        Case savedCase = caseRepository.save(newCase);

        // Attach SLA policy and calculate deadlines (US-21)
        slaService.attachSlaToCase(savedCase);

        // US-11: Publish event to trigger AI analysis asynchronously.
        // This runs after the case is persisted so the AI service can load it.
        // If AI analysis fails, it is logged gracefully — case creation is unaffected (US-15).
        eventPublisher.publishEvent(new CaseCreatedEvent(savedCase.getId()));

        Set<CaseStatus> nextStatuses = lifecycleService.getNextPossibleStatuses(savedCase.getStatus());
        return CaseDetailResponse.fromEntity(savedCase, nextStatuses);
    }

    @Transactional(readOnly = true)
    public CaseDetailResponse getCaseById(UUID caseId) {
        Case c = caseRepository.findById(caseId)
                .orElseThrow(() -> new ResourceNotFoundException("Case not found with ID: " + caseId));
        Set<CaseStatus> nextStatuses = lifecycleService.getNextPossibleStatuses(c.getStatus());
        return CaseDetailResponse.fromEntity(c, nextStatuses);
    }

    @Transactional(readOnly = true)
    public Page<CaseSummaryResponse> listMyCases(UserPrincipal principal, Pageable pageable) {
        return caseRepository.findByRequesterId(principal.getId(), pageable)
                .map(CaseSummaryResponse::fromEntity);
    }

    @Transactional(readOnly = true)
    public Page<CaseSummaryResponse> listAssignedCases(UserPrincipal principal, Pageable pageable) {
        return caseRepository.findByAssignedUserId(principal.getId(), pageable)
                .map(CaseSummaryResponse::fromEntity);
    }

    @Transactional(readOnly = true)
    public Page<CaseSummaryResponse> listTeamCases(UUID teamId, Pageable pageable) {
        return listTeamCases(teamId, null, pageable);
    }

    @Transactional(readOnly = true)
    public Page<CaseSummaryResponse> listTeamCases(UUID teamId, UUID orgId, Pageable pageable) {
        if (teamId != null) {
            return caseRepository.findByAssignedTeamId(teamId, pageable)
                    .map(CaseSummaryResponse::fromEntity);
        } else if (orgId != null) {
            return caseRepository.findByCategoryOrganizationId(orgId, pageable)
                    .map(CaseSummaryResponse::fromEntity);
        } else {
            return Page.empty(pageable);
        }
    }

    @Transactional(readOnly = true)
    public Page<CaseSummaryResponse> listAllCases(CaseStatus status, Priority priority, Severity severity,
                                                  UUID categoryId, Pageable pageable) {
        Specification<Case> spec = Specification.where(null);

        if (status != null) {
            spec = spec.and((root, query, cb) -> cb.equal(root.get("status"), status));
        }
        if (priority != null) {
            spec = spec.and((root, query, cb) -> cb.equal(root.get("priority"), priority));
        }
        if (severity != null) {
            spec = spec.and((root, query, cb) -> cb.equal(root.get("severity"), severity));
        }
        if (categoryId != null) {
            spec = spec.and((root, query, cb) -> cb.equal(root.get("category").get("id"), categoryId));
        }

        return caseRepository.findAll(spec, pageable)
                .map(CaseSummaryResponse::fromEntity);
    }

    /**
     * US-34: Advanced multi-criteria search and filter.
     */
    @Transactional(readOnly = true)
    public Page<CaseSummaryResponse> searchCases(CaseSearchRequest request, UUID organizationId, Pageable pageable) {
        Specification<Case> spec = CaseSpecification.withFilters(request, organizationId);
        return caseRepository.findAll(spec, pageable)
                .map(CaseSummaryResponse::fromEntity);
    }

    @Transactional
    public CaseDetailResponse updateCaseStatus(UUID caseId, UpdateCaseStatusRequest request, UserPrincipal principal) {
        Case c = caseRepository.findById(caseId)
                .orElseThrow(() -> new ResourceNotFoundException("Case not found with ID: " + caseId));

        // Validate state machine transition
        lifecycleService.validateTransition(c.getStatus(), request.getStatus());

        c.setStatus(request.getStatus());

        if (request.getStatus() == CaseStatus.RESOLUTION_PROPOSED && c.getResolvedAt() == null) {
            c.setResolvedAt(Instant.now());
            slaService.recordCaseResolution(caseId);
        }
        if (request.getStatus() == CaseStatus.CLOSED) {
            c.setClosedAt(Instant.now());
            if (c.getResolvedAt() == null) {
                c.setResolvedAt(Instant.now());
            }
            slaService.recordCaseResolution(caseId);
        }
        if (request.getStatus() == CaseStatus.REOPENED) {
            c.setClosedAt(null);
            c.setResolvedAt(null);
        }

        Case updatedCase = caseRepository.save(c);
        Set<CaseStatus> nextStatuses = lifecycleService.getNextPossibleStatuses(updatedCase.getStatus());
        return CaseDetailResponse.fromEntity(updatedCase, nextStatuses);
    }

    @Transactional
    public CaseDetailResponse assignCase(UUID caseId, AssignCaseRequest request, UserPrincipal principal) {
        Case c = caseRepository.findById(caseId)
                .orElseThrow(() -> new ResourceNotFoundException("Case not found with ID: " + caseId));

        User assigningUser = userRepository.findById(principal.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Assigning user not found"));

        User targetUser = null;
        if (request.getAssignedUserId() != null) {
            targetUser = userRepository.findById(request.getAssignedUserId())
                    .orElseThrow(() -> new ResourceNotFoundException("Assigned user not found"));
            c.setAssignedUser(targetUser);
        }

        Team targetTeam = null;
        if (request.getAssignedTeamId() != null) {
            targetTeam = teamRepository.findById(request.getAssignedTeamId())
                    .orElseThrow(() -> new ResourceNotFoundException("Assigned team not found"));
            c.setAssignedTeam(targetTeam);
        }

        // Automatic state progression if newly assigned from UNDERSTOOD or REPORTED
        if (c.getStatus() == CaseStatus.REPORTED && lifecycleService.isValidTransition(c.getStatus(), CaseStatus.UNDERSTOOD)) {
            c.setStatus(CaseStatus.UNDERSTOOD);
        }
        if (c.getStatus() == CaseStatus.UNDERSTOOD && lifecycleService.isValidTransition(c.getStatus(), CaseStatus.ASSIGNED)) {
            c.setStatus(CaseStatus.ASSIGNED);
        }

        Case savedCase = caseRepository.save(c);

        // Record Assignment History
        CaseAssignment assignmentHistory = new CaseAssignment(savedCase, targetUser, targetTeam, assigningUser);
        caseAssignmentRepository.save(assignmentHistory);

        Set<CaseStatus> nextStatuses = lifecycleService.getNextPossibleStatuses(savedCase.getStatus());
        return CaseDetailResponse.fromEntity(savedCase, nextStatuses);
    }

    private synchronized String generateCaseNumber() {
        String dateStr = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        long count = caseRepository.countByDatePattern(dateStr);
        return String.format("NEX-%s-%04d", dateStr, count + 1);
    }
}
