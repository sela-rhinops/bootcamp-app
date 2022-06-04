
# Week 3  - Weight Tracker App Installation 


## Part 1 Postgres Installation

    1. Connect to vm (db server) using provided ssh key
        - We can use MobaXterm tool to connect to db server using existing ssh key.
        - Or create ppk key using provided ssh key using puttygen tool, and putty to connect db server.
    2. After connected to db server terminal follow instructions in below link.
        https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-18-04 
    3. Change listen_addresses='*' in postgresql.config
    4. Whitelist IPs in pg_hba.config so allowed machines can connect to postgres db. Add entry of application server's ip so application server can communicate with db.
    5. Test connection from app server or from any machine whose ip is whitelisted in pg_hba.config
            connect using postgres client or any db client.
    5. Connect to postgres and set password to postgres user.
    6. Login into db and create database "weighttrackerdb".  
    
## Part 2 Weight Tracker App Deployment

    1. Install node 14 on application server
        https://computingforgeeks.com/install-node-js-14-on-ubuntu-debian-linux/
    2. Login to Github
    3. Fork repository https://github.com/sela-rhinops/bootcamp-app
    4. SSH to application server
    5. Clone fork repository on applicatin server
            sudo git clone <fork repository>
    6. Register application in okta and get clientId and clientSecret
    7. Add below environment variables in .env file (add file in application root folder if not exists)
        COOKIE_ENCRYPT_PWD=<32 character long password string >
        OKTA_ORG_URL=<okata org url>
        HOST_URL=http://<application server external ip : port>
        OKTA_CLIENT_ID=<okta client id>
        OKTA_CLIENT_SECRET=<okta client secret>
        NODE_ENV=production
        PORT=<application port>
        HOST=<application server internal ip>
        PGHOST=<postgres server internal ip>
        PGUSERNAME=<postgres username>
        PGDATABASE=<weight tracker db name>
        PGPASSWORD=<db password>
        PGPORT=<postgres db port> 
    8. Change directory where weight tracker application cloned.
    9. Run below commands 
        npm install - install project dependencies
        npm run initdb - this will create required tables in db
    10. Run application 
        npm run dev
    11. Access application from browser http://<application server external ip>:8080
    
## Application auto start when server restarts
    PM2 [https://pm2.keymetrics.io/] help us to auto start application, install it using
    npm install pm2@latest -g

    Start your application
    pm2 start src/index.js

    Check Status 
    pm2 l
    

## Demo

Access application from browser http://<application server external ip>:8080


## Authors

- [@vikrantbarde](https://github.com/vikrantx/sela-devops-bootcamp)
