# BUILDER
FROM node:22.22-alpine3.24 AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# RUNTIME
FROM node:22.22-alpine3.24

WORKDIR /app

COPY --from=build /app /app

EXPOSE 8000

CMD ["npm", "run", "start"]