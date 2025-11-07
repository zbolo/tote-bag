# Use Node.js v24 - Plain JavaScript, no TypeScript
FROM node:24-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY src ./src

EXPOSE 3000

# Run JavaScript directly with Node.js v24
CMD ["node", "src/index.js"]
