FROM node:9-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install --production && npm install jest

COPY . .

RUN npm run test:integration 

RUN npm prune --production=true  && rm -rf test 

FROM mhart/alpine-node:base-9.0.0
WORKDIR /app
COPY --from=builder /app ./

CMD ["node", "./bin/www"]
