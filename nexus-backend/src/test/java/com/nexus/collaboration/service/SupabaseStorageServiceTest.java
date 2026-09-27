package com.nexus.collaboration.service;

import com.nexus.common.exception.BadRequestException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockMultipartFile;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class SupabaseStorageServiceTest {

    @Mock
    private StorageService fallbackStorage;

    private SupabaseStorageService supabaseStorageService;

    @BeforeEach
    void setUp() {
        supabaseStorageService = new SupabaseStorageService(
                "https://testproject.supabase.co",
                "test-service-key",
                "nexus-attachments",
                fallbackStorage
        );
    }

    @Test
    @DisplayName("Should throw BadRequestException when file is null or empty")
    void shouldThrowBadRequest_whenFileIsEmpty() {
        MockMultipartFile emptyFile = new MockMultipartFile("file", "test.png", "image/png", new byte[0]);

        assertThatThrownBy(() -> supabaseStorageService.storeFile(emptyFile))
                .isInstanceOf(BadRequestException.class)
                .hasMessageContaining("Cannot upload an empty file");

        assertThatThrownBy(() -> supabaseStorageService.storeFile(null))
                .isInstanceOf(BadRequestException.class);
    }

    @Test
    @DisplayName("Should fallback to local storage when Supabase credentials are missing")
    void shouldFallback_whenCredentialsMissing() {
        SupabaseStorageService unconfiguredService = new SupabaseStorageService(
                "",
                "",
                "nexus-attachments",
                fallbackStorage
        );

        MockMultipartFile file = new MockMultipartFile("file", "invoice.pdf", "application/pdf", "data".getBytes());
        when(fallbackStorage.storeFile(file)).thenReturn("/storage/local-uuid.pdf");

        String result = unconfiguredService.storeFile(file);

        assertThat(result).isEqualTo("/storage/local-uuid.pdf");
        verify(fallbackStorage).storeFile(file);
    }

    @Test
    @DisplayName("Should fallback to local storage gracefully if remote upload encounters an error")
    void shouldFallback_whenRemoteUploadFails() {
        // Points to an unreachable host to trigger exception in rest client
        SupabaseStorageService faultyHostService = new SupabaseStorageService(
                "http://unreachable.invalid.supabase.test",
                "bad-key",
                "nexus-attachments",
                fallbackStorage
        );

        MockMultipartFile file = new MockMultipartFile("file", "log.txt", "text/plain", "hello".getBytes());
        when(fallbackStorage.storeFile(file)).thenReturn("/storage/fallback-file.txt");

        String result = faultyHostService.storeFile(file);

        assertThat(result).isEqualTo("/storage/fallback-file.txt");
        verify(fallbackStorage).storeFile(file);
    }
}
