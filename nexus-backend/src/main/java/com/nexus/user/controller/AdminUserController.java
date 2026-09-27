package com.nexus.user.controller;

import com.nexus.auth.security.UserPrincipal;
import com.nexus.common.response.ApiResponse;
import com.nexus.user.dto.UpdateUserRoleRequest;
import com.nexus.user.dto.UserDto;
import com.nexus.user.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

/**
 * REST controller for Administrative user management and role governance.
 */
@RestController
@RequestMapping("/api/v1/admin/users")
public class AdminUserController {

    private final UserService userService;

    public AdminUserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * Lists all users within the admin's organization.
     *
     * @param principal authenticated user principal
     * @return list of UserDto wrapped in ApiResponse
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'MANAGER', 'TEAM_LEAD')")
    public ResponseEntity<ApiResponse<List<UserDto>>> listUsers(
            @AuthenticationPrincipal UserPrincipal principal) {
        List<UserDto> users = userService.listUsers(principal.getOrganizationId());
        return ResponseEntity.ok(ApiResponse.success(users, "User directory retrieved successfully"));
    }

    /**
     * Updates an existing user's role.
     *
     * @param id target user UUID
     * @param request UpdateUserRoleRequest containing new role
     * @param principal authenticated admin user principal
     * @return updated UserDto wrapped in ApiResponse
     */
    @PutMapping("/{id}/role")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<UserDto>> updateUserRole(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateUserRoleRequest request,
            @AuthenticationPrincipal UserPrincipal principal) {
        UserDto updated = userService.updateUserRole(id, request.getRole(), principal.getOrganizationId());
        return ResponseEntity.ok(ApiResponse.success(updated, "User role updated successfully"));
    }
}
