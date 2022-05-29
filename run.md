https://blog.internetz.me/posts/kubernetes-nodejs-postgresql-example/

git clone https://github.com/johnmogi/bootcamp-app.git
cd bootcamp-app/  
 npm i

docker pull postgres:latest
docker run -d --name measurements -p 5432:5432 -e 'POSTGRES_PASSWORD=p@ssw0rd42' postgres

npm run initdb

-fail? check node version
https://tecadmin.net/install-nodejs-with-nvm/
sudo apt update && sudo apt install curl -y
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
source ~/.profile
node -v - 14

retry on an ew okta?
http://localhost:8080/authorization-code/callback
Your request resulted in an error. The 'redirect_uri' parameter must be a Login redirect URI in the client app settings: https://dev-96311573-admin.okta.com/admin/app/oidc_client/instance/0oa51n6f7t0sYDz4v5d7#tab-general

deleted app, recreate - oauth 2, web
assign users to app
https://dev-96311573-admin.okta.com/admin/apps/active

server run has the project installed - the nodejs

1st site needs nginx, and reversed proxy
i also need to connect db between servers - hosts? ssh?
postgres using docker expose port

https://docs.docker.com/samples/postgresql_service/
https://techexpert.tips/postgresql/postgresql-docker-installation/

https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-20-04

so, nginex is sort of installed, need to :
pm2
expose port 80
make site live then connect db as second stage.
map port? connect default?

sudo systemctl start pm2-ubuntu
