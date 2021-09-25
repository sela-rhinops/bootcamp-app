#!/bin/bash

if ! lsof -i:8080
then
    echo app is runing on port 8080  to see on your browser go to http://34.90.48.244:8080/ ;
    npm run dev  --prefix /home/ubuntu/bootcamp-app
    # npm run dev;
else
    echo port 8080 is occupied kiling prot and starting the app ;
    kill $(lsof -t -i:8080);
    echo app is runing on port 8080  to see on your browser go to http://34.90.48.244:8080/ ;
    npm run dev  --prefix /home/ubuntu/bootcamp-app
    # npm run dev;
    /home/ubuntu/bootcamp-app/run _app_at_startup.sh
    
fi
