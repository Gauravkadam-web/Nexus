package com.nexus.casemanagement.controller;

import com.nexus.auth.security.UserPrincipal;
import com.nexus.casemanagement.dto.*;
import com.nexus.casemanagement.entity.CaseStatus;
import com.nexus.casemanagement.entity.Priority;
import com.nexus.casemanagement.entity.Severity;
import com.nexus.casemanagement.service.CaseService;
import com.nexus.common.response.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * Core Case Management REST Endpoints covering US-1 to US-5.
 */
@RestController
@RequestMapping("/api/v1/cases")
public class CaseController {

    private final CaseService caseService;

    public CaseController(CaseService caseService) {
        this.caseService = caseService;
    }

    /**
     * US-1: Requester creates a case.
     */
    @PostMapping
    public ResponseEntity<ApiResponse<CaseDetailResponse>> createCase(
            @Valid @RequestBody CreateCaseRequest request,
            @AuthenticationPrincipal UserPrincipal principal) {
        CaseDetailResponse response = caseService.createCase(request, principal);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Case created successfully with case number: " + response.getCaseNumber()));
    }

    /**
     * Get case details by ID.
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<CaseDetailResponse>> getCaseById(@PathVariable UUID id) {
        CaseDetailResponse response = caseService.getCaseById(id);
        return ResponseEntity.ok(ApiResponse.success(response, "Case retrieved successfully"));
    }

    /**
     * US-2: Requester views their submitted cases.
     */
    @GetMapping("/my")
    public ResponseEntity<ApiResponse<Page<CaseSummaryResponse>>> getMyCases(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir,
            @AuthenticationPrincipal UserPrincipal principal) {

        Sort sort = sortDir.equalsIgnoreCase("asc") ? Sort.by(sortBy).ascending() : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<CaseSummaryResponse> cases = caseService.listMyCases(principal, pageable);
        return ResponseEntity.ok(ApiResponse.success(cases, "My cases retrieved successfully"));
    }

    /**
     * US-3: Operator views assigned cases.
     */
    @GetMapping("/assigned")
    @PreAuthorize("hasAnyRole('OPERATOR', 'TEAM_LEAD', 'MANAGER', 'ADMIN')")
    public ResponseEntity<ApiResponse<Page<CaseSummaryResponse>>> getAssignedCases(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir,
            @AuthenticationPrincipal UserPrincipal principal) {

        Sort sort = sortDir.equalsIgnoreCase("asc") ? Sort.by(sortBy).ascending() : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<CaseSummaryResponse> cases = caseService.listAssignedCases(principal, pageable);
        return ResponseEntity.ok(ApiResponse.success(cases, "Assigned cases retrieved successfully"));
    }

    /**
     * US-5: Team Lead views team cases.
     */
    @GetMapping("/team")
    @PreAuthorize("hasAnyRole('OPERATOR', 'TEAM_LEAD', 'MANAGER', 'ADMIN')")
    public ResponseEntity<ApiResponse<Page<CaseSummaryResponse>>> getTeamCases(
            @RequestParam(required = false) UUID teamId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir,
            @AuthenticationPrincipal UserPrincipal principal) {

        Sort sort = sortDir.equalsIgnoreCase("asc") ? Sort.by(sortBy).ascending() : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<CaseSummaryResponse> cases = caseService.listTeamCases(
                teamId,
                principal != null ? principal.getOrganizationId() : null,
                pageable
        );
        return ResponseEntity.ok(ApiResponse.success(cases, "Team cases retrieved successfully"));
    }

    /**
     * General Case Search and Listing with filters.
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('OPERATOR', 'TEAM_LEAD', 'MANAGER', 'ADMIN')")
    public ResponseEntity<ApiResponse<Page<CaseSummaryResponse>>> getAllCases(
            @RequestParam(required = false) CaseStatus status,
            @RequestParam(required = false) Priority priority,
            @RequestParam(required = false) Severity severity,
            @RequestParam(required = false) UUID categoryId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("asc") ? Sort.by(sortBy).ascending() : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<CaseSummaryResponse> cases = caseService.listAllCases(status, priority, severity, categoryId, pageable);
        return ResponseEntity.ok(ApiResponse.success(cases, "Cases retrieved successfully"));
    }

    /**
     * US-34: Advanced multi-criteria Case Search.
     */
    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('OPERATOR', 'TEAM_LEAD', 'MANAGER', 'ADMIN')")
    public ResponseEntity<ApiResponse<Page<CaseSummaryResponse>>> searchCases(
            @ModelAttribute CaseSearchRequest request,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir,
            @AuthenticationPrincipal UserPrincipal principal) {

        Sort sort = sortDir.equalsIgnoreCase("asc") ? Sort.by(sortBy).ascending() : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(page, size, sort);

        UUID orgId = principal != null ? principal.getOrganizationId() : null;
        Page<CaseSummaryResponse> cases = caseService.searchCases(request, orgId, pageable);
        return ResponseEntity.ok(ApiResponse.success(cases, "Cases matching search criteria retrieved successfully"));
    }

    /**
     * US-4: Operator updates case status with lifecycle transition validation.
     */
    @PatchMapping("/{id}/status")
    @PreAuthorize("hasAnyRole('OPERATOR', 'TEAM_LEAD', 'MANAGER', 'ADMIN')")
    public ResponseEntity<ApiResponse<CaseDetailResponse>> updateCaseStatus(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateCaseStatusRequest request,
            @AuthenticationPrincipal UserPrincipal principal) {
        CaseDetailResponse response = caseService.updateCaseStatus(id, request, principal);
        return ResponseEntity.ok(ApiResponse.success(response, "Case status updated successfully to: " + response.getStatus()));
    }

    /**
     * Assign case to user or team.
     */
    @RequestMapping(value = "/{id}/assign", method = {RequestMethod.POST, RequestMethod.PATCH})
    @PreAuthorize("hasAnyRole('OPERATOR', 'TEAM_LEAD', 'MANAGER', 'ADMIN')")
    public ResponseEntity<ApiResponse<CaseDetailResponse>> assignCase(
            @PathVariable UUID id,
            @Valid @RequestBody AssignCaseRequest request,
            @AuthenticationPrincipal UserPrincipal principal) {
        CaseDetailResponse response = caseService.assignCase(id, request, principal);
        return ResponseEntity.ok(ApiResponse.success(response, "Case assignment updated successfully"));
    }
}
