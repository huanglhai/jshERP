FROM maven:3.6.3-openjdk-8 AS builder

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

FROM eclipse-temurin:8-jre-alpine

WORKDIR /app

COPY --from=builder /app/target/jshERP.jar /app/jshERP.jar

EXPOSE 9999

ENTRYPOINT ["java", "-jar", "/app/jshERP.jar"]
