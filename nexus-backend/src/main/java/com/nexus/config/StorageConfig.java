package com.nexus.config;

import com.nexus.collaboration.service.LocalStorageService;
import com.nexus.collaboration.service.StorageService;
import com.nexus.collaboration.service.SupabaseStorageService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

@Configuration
public class StorageConfig {

    @Value("${nexus.storage.provider:local}")
    private String storageProvider;

    @Value("${nexus.storage.supabase.url:}")
    private String supabaseUrl;

    @Value("${nexus.storage.supabase.key:}")
    private String supabaseKey;

    @Value("${nexus.storage.supabase.bucket:nexus-attachments}")
    private String supabaseBucket;

    /**
     * Configures the primary {@link StorageService} bean based on the {@code STORAGE_PROVIDER} environment variable.
     * Defaults to {@link LocalStorageService} if provider is "local" or if Supabase is unconfigured.
     */
    @Bean
    @Primary
    public StorageService storageService(LocalStorageService localStorageService) {
        if ("supabase".equalsIgnoreCase(storageProvider)) {
            return new SupabaseStorageService(supabaseUrl, supabaseKey, supabaseBucket, localStorageService);
        }
        return localStorageService;
    }
}
