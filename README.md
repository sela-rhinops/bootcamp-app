# Node.js Weight Tracker

<a href="https://www.youtube.com/watch?v=CbTpxKKyyNg" target="_blank">
Come see a short video describing this project :

[![IMAGE ALT TEXT](http://img.youtube.com/vi/9Jt0LIvXOAE/0.jpg)](https://www.youtube.com/watch?v=9Jt0LIvXOAE" "Portfolio video #2 - the weightapp tracker p1 - manual build on azure cloud
")

</a>
<br/>

![Demo](docs/build-weight-tracker-app-demo.gif)

This sample application demonstrates the following technologies.

- [hapi](https://hapi.dev) - a wonderful Node.js application framework
- [PostgreSQL](https://www.postgresql.org/) - a popular relational database
- [Postgres](https://github.com/porsager/postgres) - a new PostgreSQL client for Node.js
- [Vue.js](https://vuejs.org/) - a popular front-end library
- [Bulma](https://bulma.io/) - a great CSS framework based on Flexbox
- [EJS](https://ejs.co/) - a great template library for server-side HTML templates

**Requirements:**

- [Node.js](https://nodejs.org/) 14.x
- [PostgreSQL](https://www.postgresql.org/) (can be installed locally using Docker)
- [Free Okta developer account](https://developer.okta.com/) for account registration, login

## Install and Configuration

1. Clone or download source files
1. Run `npm install` to install dependencies
1. If you don't already have PostgreSQL, set up using Docker
1. Create a [free Okta developer account](https://developer.okta.com/) and add a web application for this app
1. Copy `.env.sample` to `.env` and change the `OKTA_*` values to your application
1. Initialize the PostgreSQL database by running `npm run initdb`
1. Run `npm run dev` to start Node.js

The associated blog post goes into more detail on how to set up PostgreSQL with Docker and how to configure your Okta account.
