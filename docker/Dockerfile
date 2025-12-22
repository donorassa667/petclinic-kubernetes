# ============================
# Stage 1: Build the application
# ============================
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /build

# Copier uniquement les fichiers nécessaires au build
COPY spring-petclinic/pom.xml .
COPY spring-petclinic/src ./src

# Build du JAR
RUN mvn clean package -DskipTests


# ============================
# Stage 2: Runtime
# ============================
FROM eclipse-temurin:17-jre

WORKDIR /app

# Sécurité : utilisateur non-root
RUN useradd -m spring
USER spring

# Copier le JAR depuis le stage build
COPY --from=build /build/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
