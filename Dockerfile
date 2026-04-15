
# =========================================================
#  React (Frontend – Production Build)
# =========================================================

# Build stage
FROM node:20 AS build

WORKDIR /app
COPY package*.json crm
RUN npm install
COPY . .
RUN npm run build

# Runtime stage
FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# =========================================================
#  Java + Maven – Multi Stage (Recommended) -- .jar file
# =========================================================
# Build stage
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
