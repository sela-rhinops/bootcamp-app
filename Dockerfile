FROM node:14.20-alpine

RUN mkdir -p /home/weight-tracker

COPY . /home/weight-tracker

COPY c:/mount/data/.env /home/weight-tracker

WORKDIR /home/weight-tracker

EXPOSE 8080

CMD ["npm", "run", "dev"]