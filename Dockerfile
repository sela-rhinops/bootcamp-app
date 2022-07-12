FROM node:14.20-alpine

RUN mkdir -p /home/weight-tracker

COPY . /home/weight-tracker

WORKDIR /home/weight-tracker

#COPY ./docker-entrypoint.sh /home/weight-tracker

#RUN chmod +x docker-entrypoint.sh

#RUN ./docker-entrypoint.sh

#ENTRYPOINT ["./docker-entrypoint.sh"]

EXPOSE 8080

CMD ["npm", "run", "dev"]
