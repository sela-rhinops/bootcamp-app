# Node.js Weight Tracker

![Demo](docs/build-weight-tracker-app-demo.gif)

This sample application demonstrates the following technologies.

* [hapi](https://hapi.dev) - a wonderful Node.js application framework
* [PostgreSQL](https://www.postgresql.org/) - a popular relational database
* [Postgres](https://github.com/porsager/postgres) - a new PostgreSQL client for Node.js
* [Vue.js](https://vuejs.org/) - a popular front-end library
* [Bulma](https://bulma.io/) - a great CSS framework based on Flexbox
* [EJS](https://ejs.co/) - a great template library for server-side HTML templates

**Requirements:**

* [Node.js](https://nodejs.org/) 14.x
* [PostgreSQL](https://www.postgresql.org/) (can be installed locally using Docker)
* [Free Okta developer account](https://developer.okta.com/) for account registration, login

## Install and Configuration

1. Clone or download source files
1. Run `npm install` to install dependencies
1. If you don't already have PostgreSQL, set up using Docker
1. Create a [free Okta developer account](https://developer.okta.com/) and add a web application for this app
1. Copy `.env.sample` to `.env` and change the `OKTA_*` values to your application
1. Initialize the PostgreSQL database by running `npm run initdb`
1. Run `npm run dev` to start Node.js

The associated blog post goes into more detail on how to set up PostgreSQL with Docker and how to configure your Okta account.
##Postgres 
install docker.io on your machine and run the following command to set postgreSQL using docker
   `docker run  -d --name measurements --restart always -p 5432:5432 -e 'POSTGRES_PASSWORD=p@ssw0rd42' postgres`
</br>**Note:Added the restart-always option to keep the db running. <br>**

## Steps to recreate Environment
Note: These steps work in ubuntu v20.04 
1. Clone the repository 
2. Create a .env file in your working dir and add the following settings and change them accordingly. </br>
------
    # Host configuration
    PORT=8080
    HOST=localhost
------
    # Postgres configuration 
    PGHOST=localhost
    PGUSERNAME=postgres
    PGDATABASE=postgres
    PGPASSWORD=p@ssw0rd42
    PGPORT=5432
**Note: Chang 'PGHOST' to the DB ip address, if you changed the database password, be sure to update the values.**

-----
    # Chang localhost to your machine's IP address
    HOST_URL=http://localhost:8080
    COOKIE_ENCRYPT_PWD=superAwesomePasswordStringThatIsAtLeast32CharactersLong!
    NODE_ENV=development
    
    # Okta configuration
    OKTA_ORG_URL=https://{yourOrgUrl}
    OKTA_CLIENT_ID={yourClientId}
    OKTA_CLIENT_SECRET={yourClientSecret}
Copy the okta app url, Client and ID Client secret values from your okta application console</br>
paste them into your .env file to replace {yourOrgUrl}, {yourClientId} and {yourClientSecret}, respectively.</br>
**Note: To create your okta web application follow the steps in [here](https://github.com/Shossi/bootcamp-app/blob/master/docs/blog-post.md)**
--------
3. You're now ready to test your weight tracker app, run:
* `npm run initdb`
* `npm run dev` </br>

Now browse to your application from`http://{IpAdress}:8080 `
4. **Application uptime</br>**
You can use various of methods to keep your application up after restarting
* pm2
* Cron job
* Dockerfile
* Add a script to your init.d file
* forever package </br>
</br> I chose to use the forever node package, it was easy to use and configure and got the job done.
</br> Installation : `npm install -g forever`
</br> and then simply run : `forever start -c "npm run dev" ./your/path` 
</br> Now your application will run in the background and start running again on boot or in the event of a crash 
