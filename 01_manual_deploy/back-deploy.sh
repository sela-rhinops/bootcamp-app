sudo apt update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo service docker start

sudo systemctl status docker
sudo usermod -aG docker ${USER}
# su - ${USER}
# azureuser sudo docker
sudo usermod -aG docker azureuser
// user not allowed!

docker pull postgres:latest
docker run -d --name measurements -p 5432:5432 -e 'POSTGRES_PASSWORD=p@ssw0rd42' postgres