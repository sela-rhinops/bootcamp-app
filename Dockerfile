FROM node:14-apline

# Create app directory
WORKDIR /home/ubuntu/bootcamp-app
# Copy web files
COPY . .
# Install npm dependencies
RUN npm install
# initializing npm
RUN npm init -y
# initializing the database part of the env file
RUN npm run initdb
# Opening port 8080 from the containter
EXPOSE 8080
# Running the application (Entrypoint?=)
CMD [ "npm", "run", "dev" ]