# Backend Dockerfile
FROM node:25-alpine AS base

WORKDIR /app

# Install wget for Docker health checks
RUN apk add --no-cache wget

# Install production dependencies
COPY package*.json ./
RUN npm ci --omit=dev

# Development stage
FROM base AS development
RUN npm ci
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

# Production stage
FROM base AS production
COPY src ./src
COPY docs ./docs
EXPOSE 3000
CMD ["node", "src/index.js"]
