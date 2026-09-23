package com.nexus.ai.config;

import com.nexus.ai.provider.AiProviderPort;
import com.nexus.ai.provider.MockAiProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Fallback and provider bean configuration for AI services.
 * Ensures a valid AiProviderPort bean is always present even if external providers are unavailable or misconfigured.
 */
@Configuration
public class AiConfig {

    private static final Logger log = LoggerFactory.getLogger(AiConfig.class);

    @Bean
    @ConditionalOnMissingBean(AiProviderPort.class)
    public AiProviderPort defaultAiProvider(@Value("${nexus.ai.provider:mock}") String provider) {
        log.info("[AiConfig] Initializing default MockAiProvider (configured provider='{}')", provider);
        return new MockAiProvider();
    }
}
