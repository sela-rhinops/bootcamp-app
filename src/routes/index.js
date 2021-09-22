"use strict";

const home = {
  method: "GET",
  path: "/",
  handler: ( request, h ) => {
    return "HELLO MOSHE ROSENBLUM!";
  }
};

module.exports = [ home ];