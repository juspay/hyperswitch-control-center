FROM node:18 AS base
WORKDIR /usr/src/app
COPY . .
ENV NODE_OPTIONS="--max-old-space-size=4096"

RUN npm i
RUN npm run build:prod
# this needs to be removed and made a separate deployment for this 
RUN npm run build:embeddedapp




FROM node:18-alpine

WORKDIR /usr/src/app
COPY --from=base /usr/src/app/dist /usr/src/app/dist
COPY --from=base /usr/src/app/package*.json ./

# Update Alpine package manager and upgrade openssl libcrypto3 libssl3
RUN apk upgrade --no-cache openssl libcrypto3 libssl3 \
 && apk add --no-cache bash

# Create non-root user and switch to it
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Give ownership of /usr/src/app to appuser
RUN chown -R appuser:appgroup /usr/src/app

USER appuser

EXPOSE 8080 9000
CMD [ "/bin/bash", "-c", "npm run serve" ]