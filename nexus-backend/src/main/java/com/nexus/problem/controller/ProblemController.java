package com.nexus.problem.controller;

import com.nexus.auth.security.UserPrincipal;
import com.nexus.common.response.ApiResponse;
import com.nexus.problem.dto.*;
import com.nexus.problem.entity.ProblemStatus;
import com.nexus.problem.service.ProblemService;
import com.nexus.problem.service.RecurringProblemDetectionService;
import com.nexus.user.entity.User;
import com.nexus.user.repository.UserRepository;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/problems")
public class ProblemController {

    private final ProblemService problemService;
    private final RecurringProblemDetectionService recurringProblemDetectionService;
    private final UserRepository userRepository;

    public ProblemController(ProblemService problemService,
                             RecurringProblemDetectionService recurringProblemDetectionService,
                             UserRepository userRepository) {
        this.problemService = problemService;
        this.recurringProblemDetectionService = recurringProblemDetectionService;
        this.userRepository = userRepository;
    }

    /**
     * List all problems in the organization.
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('OPERATOR', 'TEAM_LEAD', 'MANAGER', 'ADMIN')")
    public ResponseEntity<ApiResponse<Page<ProblemResponse>>> listProblems(
            @RequestParam(required = false) ProblemStatus status,
            @AuthenticationPrincipal UserPrincipal principal,
            Pageable pageable) {
        Page<ProblemResponse> response = problemService.listProblems(principal.getOrganizationId(), status, pageable);
        return ResponseEntity.ok(ApiResponse.success(response, "Problems retrieved successfully"));
    }

    /**
     * US-28: Create a formal Problem record.
     */
    @PostMapping
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    public ResponseEntity<ApiResponse<ProblemResponse>> createProblem(
            @Valid @RequestBody CreateProblemRequest request,
            @AuthenticationPrincipal UserPrincipal principal) {
        User creator = userRepository.findById(principal.getId()).orElse(null);
        ProblemResponse response = problemService.createProblem(request, principal.getOrganizationId(), creator);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Problem created successfully"));
    }

    /**
     * Get problem by ID.
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('TEAM_LEAD', 'MANAGER', 'ADMIN')")
    public ResponseEntity<ApiResponse<ProblemResponse>> getProblemById(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserPrincipal principal) {
        ProblemResponse response = problemService.getProblemById(id, principal.getOrganizationId());
        return ResponseEntity.ok(ApiResponse.success(response, "Problem retrieved successfully"));
    }

    /**
     * Update problem details and root-cause findings.
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    public ResponseEntity<ApiResponse<ProblemResponse>> updateProblem(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateProblemRequest request,
            @AuthenticationPrincipal UserPrincipal principal) {
        ProblemResponse response = problemService.updateProblem(id, request, principal.getOrganizationId());
        return ResponseEntity.ok(ApiResponse.success(response, "Problem updated successfully"));
    }

    /**
     * Link an incident case to a problem.
     */
    @PostMapping("/{id}/incidents")
    @PreAuthorize("hasAnyRole('TEAM_LEAD', 'MANAGER', 'ADMIN')")
    public ResponseEntity<ApiResponse<ProblemResponse>> linkIncident(
            @PathVariable UUID id,
            @Valid @RequestBody LinkIncidentRequest request,
            @AuthenticationPrincipal UserPrincipal principal) {
        ProblemResponse response = problemService.linkIncident(id, request.getCaseId(), principal.getOrganizationId());
        return ResponseEntity.ok(ApiResponse.success(response, "Incident linked to problem successfully"));
    }

    /**
     * US-28: Automatically detect recurring problem clusters.
     */
    @GetMapping("/recurring-patterns")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<RecurringProblemClusterResponse>>> getRecurringPatterns(
            @AuthenticationPrincipal UserPrincipal principal) {
        List<RecurringProblemClusterResponse> response =
                recurringProblemDetectionService.detectRecurringProblemPatterns(principal.getOrganizationId());
        return ResponseEntity.ok(ApiResponse.success(response, "Recurring problem patterns retrieved successfully"));
    }
}
