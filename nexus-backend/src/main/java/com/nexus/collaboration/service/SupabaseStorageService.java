package com.nexus.collaboration.service;

import com.nexus.common.exception.BadRequestException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.client.RestClient;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

/**
 * Supabase Storage implementation of {@link StorageService}.
 * Uploads case attachments directly to a Supabase Storage bucket via REST API.
 * Gracefully falls back to local storage if credentials are missing or remote upload fails.
 */
public class SupabaseStorageService implements StorageService {

    private static final Logger log = LoggerFactory.getLogger(SupabaseStorageService.class);

    private final String supabaseUrl;
    private final String supabaseKey;
    private final String bucketName;
    private final StorageService fallbackStorage;
    private final RestClient restClient;

    public SupabaseStorageService(String supabaseUrl, String supabaseKey, String bucketName, StorageService fallbackStorage) {
        this.supabaseUrl = supabaseUrl != null ? supabaseUrl.replaceAll("/+$", "") : "";
        this.supabaseKey = supabaseKey != null ? supabaseKey.trim() : "";
        this.bucketName = bucketName != null && !bucketName.isBlank() ? bucketName.trim() : "nexus-attachments";
        this.fallbackStorage = fallbackStorage;
        this.restClient = RestClient.builder().build();
    }

    @Override
    public String storeFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BadRequestException("Cannot upload an empty file");
        }

        // If credentials are not configured, fall back to local disk storage
        if (supabaseUrl.isBlank() || supabaseKey.isBlank()) {
            log.warn("Supabase Storage credentials not configured (SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY missing). Falling back to local storage.");
            return fallbackStorage.storeFile(file);
        }

        String originalFilename = file.getOriginalFilename();
        String extension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }

        String generatedFilename = UUID.randomUUID() + extension;
        String objectPath = "cases/" + generatedFilename;

        try {
            byte[] fileBytes = file.getBytes();
            String contentType = (file.getContentType() != null && !file.getContentType().isBlank())
                    ? file.getContentType()
                    : MediaType.APPLICATION_OCTET_STREAM_VALUE;

            String uploadUrl = String.format("%s/storage/v1/object/%s/%s", supabaseUrl, bucketName, objectPath);

            restClient.post()
                    .uri(uploadUrl)
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + supabaseKey)
                    .header("apikey", supabaseKey)
                    .header(HttpHeaders.CONTENT_TYPE, contentType)
                    .body(fileBytes)
                    .retrieve()
                    .toBodilessEntity();

            String publicUrl = String.format("%s/storage/v1/object/public/%s/%s", supabaseUrl, bucketName, objectPath);
            log.info("File successfully uploaded to Supabase Storage: {}", publicUrl);
            return publicUrl;
        } catch (Exception ex) {
            log.error("Failed to upload file to Supabase Storage: {}. Gracefully falling back to local storage.", ex.getMessage());
            return fallbackStorage.storeFile(file);
        }
    }
}
