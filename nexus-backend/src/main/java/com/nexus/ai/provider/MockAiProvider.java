package com.nexus.ai.provider;

import com.nexus.ai.dto.CaseContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.math.BigDecimal;

import java.util.List;

/**
 * Mock AI provider for local development and testing (AI_PROVIDER=mock).
 * Returns deterministic, canned responses without making any external API calls.
 * This ensures tests run offline and no AI costs are incurred in dev/CI.
 */
public class MockAiProvider implements AiProviderPort {

    private static final Logger log = LoggerFactory.getLogger(MockAiProvider.class);

    @Override
    public AiAnalysisResult analyzeCase(CaseContext context) {
        log.info("[MockAI] analyzeCase called for case: {}", context.getCaseNumber());

        AiAnalysisResult result = new AiAnalysisResult();
        result.setSuggestedPriority("HIGH");
        result.setSuggestedSeverity("MEDIUM");
        result.setSuggestedCategoryName(context.getCategoryName());
        result.setSuggestedTeamName("Support Team");
        result.setMissingInformation(List.of("error_message", "device_model", "steps_to_reproduce"));
        result.setRecommendedNextAction(
                "Request the exact error message from the requester and check recent system logs.");
        result.setRiskInformation("{\"level\":\"LOW\",\"factors\":[]}");
        result.setConfidence(new BigDecimal("0.82"));
        result.setModelInformation("mock/nexus-ai-v1");
        return result;
    }

    @Override
    public String generateSummary(CaseContext context) {
        log.info("[MockAI] generateSummary called for case: {}", context.getCaseNumber());
        return String.format(
                "Case %s — %s. Original report: %s. " +
                "Status: %s. " +
                "Confirmed findings: Under investigation. " +
                "Remaining work: Awaiting additional information from requester.",
                context.getCaseNumber(),
                context.getTitle(),
                context.getDescription(),
                context.getCurrentStatus()
        );
    }

    @Override
    public String detectMissingInformation(CaseContext context) {
        log.info("[MockAI] detectMissingInformation called for case: {}", context.getCaseNumber());
        return "The following information appears to be missing: exact error message or code, " +
               "device model and operating system version, and steps to reproduce the issue.";
    }

    @Override
    public String askCopilot(CaseContext context, String question) {
        log.info("[MockAI] askCopilot called for case: {} with question: {}", context.getCaseNumber(), question);
        return String.format(
                "Copilot Analysis for Case %s (%s): Based on the current findings and history (%s), " +
                "regarding your query '%s': The case is currently in status %s with priority %s. " +
                "Recommended next step is to continue investigating logged findings.",
                context.getCaseNumber(),
                context.getTitle(),
                context.getDescription(),
                question,
                context.getCurrentStatus(),
                context.getCurrentPriority()
        );
    }

    @Override
    public String draftCommunication(CaseContext context, String audience, String intent, String instructions) {
        log.info("[MockAI] draftCommunication called for case: {}, audience: {}, intent: {}", 
                context.getCaseNumber(), audience, intent);
        return String.format(
                "Dear %s,\n\nWe are providing an update regarding Case %s: '%s'. " +
                "Our team is actively handling this item (Status: %s). %s\n\n" +
                "Thank you for your patience.\nNexus Support Team",
                "REQUESTER".equalsIgnoreCase(audience) ? "Requester" : audience,
                context.getCaseNumber(),
                context.getTitle(),
                context.getCurrentStatus(),
                instructions != null && !instructions.isBlank() ? "Note: " + instructions : "We will notify you as soon as further progress is made."
        );
    }
}
