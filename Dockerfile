FROM node:18-alpine AS builder
WORKDIR /app

# Install dependencies only when package files change (cache-friendly)
COPY package.json package-lock.json ./
RUN npm ci --silent

# Copy rest and build
COPY . .
RUN npm run build

# Stage 2 - production image
FROM nginx:stable-alpine AS production
# Remove default site
RUN rm -rf /usr/share/nginx/html/*
# Copy build output to nginx
COPY --from=builder /app/build /usr/share/nginx/html

# Optional: copy custom nginx config for SPA fallback if present
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]