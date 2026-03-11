# Use Node.js v25 - Plain JavaScript, no TypeScript
FROM node:25-alpine

# Install wget for Docker health checks
RUN apk add --no-cache wget

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY src ./src
COPY docs ./docs

EXPOSE 3000

# Run JavaScript directly with Node.js v25
CMD ["node", "src/index.js"]
