# Node.js Weight Tracker

The associated blog post goes into more detail on how to configure your Okta account.
##Postgres 
install docker.io on your machine and run the following command to set postgreSQL using docker
   `docker run  -d --name measurements --restart always -p 5432:5432 -e 'POSTGRES_PASSWORD=p@ssw0rd42' postgres`
</br>**Note:Added the restart-always option to keep the db running. <br>**
Change the postgreSQL server to a managed sql server on azure.

## Steps to recreate Environment
Note: These steps work in ubuntu v20.04

### **1. Creating the .env file (create it in the application working dir)**
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

**Note: Chang 'PGHOST' to the DB ip address, username(if you changed it) and the database password.**

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

### **2. Building the docker image**
The dockerfile contains all the needed commands to run the application
```
docker build -tag "tag" .
```
Pushing the image to Docker hub
```
docker login
docker push 'tag'
```
------------------
### **3. Ansible**
Installing Ansible: 
```
sudo apt update
sudo apt install software-properties-common -y
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y
```
Edit inv.ini file to match corresponding servers ip's and password to the web servers</br>
After editing the inv.ini file you can check your connection to the servers with the following command </br>
```
ansible servers -m ping
```
Running the playbook
```
ansible-playbook 'name'.yaml -i inv.ini
```
### 4.Infrastructure
Infrastructure is created with [terraform](https://github.com/Shossi/Terraform-Weight), and it contains the following: </br>

### **prod:**</br>
- a virtual network, 2 subnets(private and public), a network security group,
- 3 instances created with a vmss, connected to a load balancer
- a managed postgreSQL service used as the db for the application
- another virtual machine used as a master node for ansible</br>
### **staging:**
- a virtual network, 2 subnets(private and public), a network security group,
- 2 instances created with a vmss, connected to a load balancer
- a managed postgreSQL service used as the db for the application
- another virtual machine used as a master node for ansible

Note: Difference between the environments is the number of instances.