FROM node:14-alpine

# Create app directory
WORKDIR /home/ubuntu/bootcamp-app
# Copy web files
COPY . .
# Install npm dependencies
# initializing the database part of the env file
# initializing npm
RUN npm install
    npm init -y
    npm run initdb
# Opening port 8080 from the containter
EXPOSE 8080
# Running the application (Entrypoint?=)
ENTRYPOINT [ "npm", "run", "dev" ]
