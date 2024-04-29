
FROM node:18 as base
WORKDIR /usr/src/app
# COPY package*.json ./
COPY . .

ARG BRANCH_NAME=hyperswitch
ARG RUN_TEST=false
RUN echo git branch is $BRANCH_NAME
RUN yarn install
RUN yarn build:prod




FROM node:18-alpine

WORKDIR /usr/src/app
COPY --from=base /usr/src/app/dist /usr/src/app/dist
COPY --from=base /usr/src/app/package*.json ./
RUN apk add --no-cache bash
RUN ls -l /usr/src/app/dist
EXPOSE 8080 9000
CMD [ "/bin/bash", "-c", "yarn serve" ]
