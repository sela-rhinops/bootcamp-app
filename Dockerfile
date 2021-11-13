FROM node:14-alpine
COPY . /bootcamp-app
WORKDIR /bootcamp-app
ARG port=8080
ENV port=$port
EXPOSE $port

RUN npm install

CMD npm run initdb && npm run dev