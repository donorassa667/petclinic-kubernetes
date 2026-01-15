# ============================
# Stage 1: Build
# ============================
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /build
COPY spring-petclinic/pom.xml .
COPY spring-petclinic/src ./src
RUN mvn clean package -DskipTests

# ============================
# Stage 2: Runtime
# ============================
FROM eclipse-temurin:17-jre
WORKDIR /app

COPY --from=build /build/target/*.jar app.jar

# Agent compatible
RUN curl -L -o opentelemetry-javaagent.jar https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v2.9.0/opentelemetry-javaagent.jar

RUN useradd -m spring && chown spring:spring /app/*
USER spring

EXPOSE 8080

# Lancer avec OpenTelemetry — DÉSACTIVER Spring Web
ENTRYPOINT ["java", "-javaagent:/app/opentelemetry-javaagent.jar", \
  "-Dotel.service.name=petclinic", \
  "-Dotel.traces.exporter=otlp", \
  "-Dotel.metrics.exporter=none", \
  "-Dotel.logs.exporter=none", \
  "-Dotel.exporter.otlp.endpoint=http://otel-collector.monitoring.svc.cluster.local:4318", \
  "-Dotel.instrumentation.spring-web.enabled=false", \
  "-Dotel.instrumentation.spring-webmvc.enabled=false", \
  "-Dotel.instrumentation.jdbc.enabled=true", \
  "-jar", "app.jar"]
