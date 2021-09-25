#!/bin/bash
#this scrip will run every time machine is restarted (using corntab)
if ! lsof -i:8080 #check if port 8080 is taken
then
    npm run dev  --prefix /home/ubuntu/bootcamp-app; #run the app
     # app is runing on port 8080  to see on your browser go to http://34.90.48.244:8080/ ;
else
    #port 8080 is occupied kiling prot and starting the app 
    kill $(lsof -t -i:8080);
    npm run dev  --prefix /home/ubuntu/bootcamp-app;  #see on your browser go to http://34.90.48.244:8080/
fi
#crontab -e
#@reboot  /home/ubuntu/bootcamp-app/run.sh