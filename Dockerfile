FROM alpine:3.15.4
# node:14

RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app

WORKDIR /home/node/app

COPY package*.json ./

USER node

COPY --chown=node:node . .
COPY . .

EXPOSE 3000

RUN npm install

CMD ["node", "run initdb"]