# =========================================================
#  React (Frontend – Production Build)
# =========================================================

# Build stage
FROM node:18 AS build

WORKDIR /app

ENV NODE_OPTIONS=--openssl-legacy-provider
COPY cms/package*.json ./
RUN npm install

COPY cms/ .
RUN npm run build

# Runtime stage
FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
