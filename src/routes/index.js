"use strict";

const home = {
  method: "GET",
  path: "/",
  handler: ( request, h ) => {
    return "hello world!";
  }
};

module.exports = [ home ];