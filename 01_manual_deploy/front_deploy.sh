sudo apt install curl

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

'''
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
'''

source ~/.bashrc
nvm list-remote
nvm install v14

git clone https://github.com/johnmogi/bootcamp-app.git
cd bootcamp-app
npm install



sudo apt update
sudo apt install nginx -y
systemctl status nginx


sudo npm install pm2@latest -g

pm2 start ./src/index.js

