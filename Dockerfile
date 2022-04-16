FROM node:14-alpine

WORKDIR /home/ubuntu/node-weight-tracker

COPY . .

RUN npm install &&\
    npm init -y &&\
    npm run initdb
	
ENV PORT=8080
	
EXPOSE 8080

ENTRYPOINT [ "npm", "run", "dev" ]
