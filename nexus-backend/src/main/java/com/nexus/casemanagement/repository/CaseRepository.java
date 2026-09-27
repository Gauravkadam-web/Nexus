package com.nexus.casemanagement.repository;

import com.nexus.casemanagement.entity.Case;
import com.nexus.casemanagement.entity.CaseStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CaseRepository extends JpaRepository<Case, UUID>, JpaSpecificationExecutor<Case> {

    Optional<Case> findByCaseNumber(String caseNumber);

    Page<Case> findByRequesterId(UUID requesterId, Pageable pageable);

    Page<Case> findByAssignedUserId(UUID assignedUserId, Pageable pageable);

    Page<Case> findByAssignedTeamId(UUID assignedTeamId, Pageable pageable);

    long countByCreatedAtBetween(Instant start, Instant end);

    @Query("SELECT COUNT(c) FROM Case c WHERE c.caseNumber LIKE CONCAT('NEX-', :datePattern, '-%')")
    long countByDatePattern(@Param("datePattern") String datePattern);

    long countByAssignedUserIdAndStatusIn(UUID assignedUserId, java.util.Collection<CaseStatus> statuses);

    long countByAssignedTeamIdAndStatusIn(UUID assignedTeamId, java.util.Collection<CaseStatus> statuses);

    long countByAssignedTeamIdAndStatus(UUID assignedTeamId, CaseStatus status);

    List<Case> findByCategoryOrganizationId(UUID orgId);

    Page<Case> findByCategoryOrganizationId(UUID orgId, Pageable pageable);

    long countByCategoryOrganizationId(UUID orgId);

    long countByCategoryOrganizationIdAndStatus(UUID orgId, CaseStatus status);

    long countByCategoryOrganizationIdAndStatusIn(UUID orgId, java.util.Collection<CaseStatus> statuses);

    long countByCategoryOrganizationIdAndCreatedAtBetween(UUID orgId, Instant start, Instant end);

    long countByCategoryOrganizationIdAndResolvedAtBetween(UUID orgId, Instant start, Instant end);

    @Query("SELECT c.category.id, c.category.name, COUNT(c) FROM Case c WHERE c.category.organization.id = :orgId GROUP BY c.category.id, c.category.name")
    List<Object[]> countCasesGroupedByCategory(@Param("orgId") UUID orgId);

    @Query("SELECT c.assignedTeam.id, c.assignedTeam.name, COUNT(c) FROM Case c WHERE c.category.organization.id = :orgId AND c.assignedTeam IS NOT NULL GROUP BY c.assignedTeam.id, c.assignedTeam.name")
    List<Object[]> countCasesGroupedByTeam(@Param("orgId") UUID orgId);
}
