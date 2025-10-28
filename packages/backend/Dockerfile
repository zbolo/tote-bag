# Use Node.js v24 with native TypeScript support
FROM node:24-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY src ./src

EXPOSE 3000

# Run TypeScript files directly with Node.js v24's native type stripping
CMD ["node", "--experimental-strip-types", "src/index.ts"]
