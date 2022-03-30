FROM node:14

# Create app directory
WORKDIR /usr/src/app
# Copy both of the package.json files (*)
COPY package*.json ./
# Install app dependencies
RUN npm install
# Bundle app source
# Copy folder contents
COPY .. .
# initializing npm
RUN npm init -y
# initializing the database part of the env file
RUN npm run initdb
# Opening port 8080 from the containter
EXPOSE 8080
# Running the application (Entrypoint?=)
CMD [ "npm", "run", "dev" ]