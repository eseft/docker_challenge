FROM alpine:3.14 AS source

RUN apk add --update --no-cache curl \
    make \
    python2 \
    g++ \
    gcc \
    gcc-doc \
    linux-headers && \
    curl -L -O https://nodejs.org/dist/v9.0.0/node-v9.0.0.tar.gz && \
    tar xzf node-v9.0.0.tar.gz && \
    cd node-v9.0.0 && \
    ./configure --partly-static --without-inspector --without-perfctr --without-node-options --without-intl --without-npm --without-dtrace --without-etw && \
    make -j4 

FROM node:9-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install --production=true && npm install jest

COPY . .

RUN npm run test:integration 
RUN npm prune --production=true  && rm -rf test 

FROM alpine:3.14
WORKDIR /app
COPY --from=source /node-v9.0.0/out/Release/node ./
COPY --from=builder /app ./

CMD ["./node", "./bin/www"]