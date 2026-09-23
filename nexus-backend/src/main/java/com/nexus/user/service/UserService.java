package com.nexus.user.service;

import com.nexus.common.exception.ResourceNotFoundException;
import com.nexus.user.dto.UserDto;
import com.nexus.user.entity.Role;
import com.nexus.user.entity.RoleType;
import com.nexus.user.entity.User;
import com.nexus.user.repository.RoleRepository;
import com.nexus.user.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Service for administrative user governance, directory retrieval, and RBAC clearance management.
 */
@Service
public class UserService {

    private static final Logger log = LoggerFactory.getLogger(UserService.class);

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;

    public UserService(UserRepository userRepository, RoleRepository roleRepository) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
    }

    /**
     * Lists all users belonging to the specified organization.
     *
     * @param organizationId the organization UUID
     * @return list of UserDto representing directory members
     */
    @Transactional(readOnly = true)
    public List<UserDto> listUsers(UUID organizationId) {
        log.info("[UserService] Fetching all directory users for organization: {}", organizationId);
        List<User> users = userRepository.findByOrganizationId(organizationId);
        return users.stream()
                .map(UserDto::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Updates the role assigned to a specific user within the organization.
     *
     * @param userId the user UUID
     * @param newRoleName the new role name (e.g. ADMIN, OPERATOR, MANAGER, TEAM_LEAD, REQUESTER)
     * @param organizationId the organization UUID
     * @return the updated UserDto
     */
    @Transactional
    public UserDto updateUserRole(UUID userId, String newRoleName, UUID organizationId) {
        log.info("[UserService] Updating user {} role to {} for org {}", userId, newRoleName, organizationId);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        if (!user.getOrganization().getId().equals(organizationId)) {
            throw new ResourceNotFoundException("User not found in organization");
        }

        RoleType roleType = RoleType.valueOf(newRoleName.trim().toUpperCase());
        Role role = roleRepository.findByName(roleType)
                .orElseThrow(() -> new ResourceNotFoundException("Role", "name", roleType.name()));

        user.getRoles().clear();
        user.getRoles().add(role);
        User updated = userRepository.save(user);
        return UserDto.fromEntity(updated);

    }
}
