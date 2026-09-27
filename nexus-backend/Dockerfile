# ==============================================================================
# Nexus Backend — Production Multi-Stage Dockerfile (Spring Boot 3.3.4 + Java 21)
# Optimized for Render Cloud Web Service deployment
# ==============================================================================

# Stage 1: Build stage with Maven and Java 21
FROM maven:3.9.9-eclipse-temurin-21-alpine AS builder
WORKDIR /build

# Copy dependency definition and download dependencies for Docker caching layer
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy project source and package executable JAR
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Ultra-lightweight JRE runtime image
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Create unprivileged runtime user for security compliance
RUN addgroup -S nexusgroup && adduser -S nexususer -G nexusgroup
USER nexususer

# Copy packaged JAR from build stage
COPY --from=builder --chown=nexususer:nexusgroup /build/target/nexus-backend-*.jar app.jar

# Render injects PORT dynamically (defaults to 8080)
ENV PORT=8080
EXPOSE 8080

# Production memory tuning for container limits
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]
