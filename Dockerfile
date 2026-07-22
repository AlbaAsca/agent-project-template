# EJEMPLO (reemplazable) — build estático de un frontend Node servido con nginx.
# Adapta o borra según tu stack real. Si tu app es de otro tipo, sustituye este Dockerfile.

# --- Stage 1: build ---
FROM node:22-alpine AS build
WORKDIR /app
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ .
RUN npm run build

# --- Stage 2: serve ---
FROM nginx:alpine AS serve
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
