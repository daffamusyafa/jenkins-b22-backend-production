# Stage 1: Build Stage
FROM node:16-alpine AS build

WORKDIR /app

COPY package*.json ./

RUN npm install

RUN npm install sequelize -g

COPY . .

RUN npx sequelize db:migrate

# Stage 2: Production Stage
FROM node:16-alpine

WORKDIR /app

COPY --from=build /app ./

RUN npm install pm2 -g

COPY ecosystem.config.js ./

CMD ["pm2-runtime", "ecosystem.config.js"]
