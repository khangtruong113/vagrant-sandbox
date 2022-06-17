#!/usr/bin/env bash

# Adding Repo
echo "-------------------------- ADDING REPO -------------------------------------"
wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list

# Updating Package Index and Installing MongoDB-5
echo "-------------------------- UPDATING PACKAGE INDEX -------------------------------------"
sudo apt update

echo "-------------------------- INSTALL PACKAGES --------------------------"
sudo apt install -y mongodb-org net-tools

# Start and Enable Mongod 
echo "-------------------------- START & ENABLE MONGOD --------------------------"
sudo systemctl enable --now mongod

sleep 20

# Create user
echo "-------------------------- CREATE VAGRANT USER --------------------------"
mongosh << BLK
use admin
db.createUser(
{
    user: "vagrant",
    pwd: "vagrant",
    roles: [
              { role: "userAdminAnyDatabase", db: "admin" },
              { role: "readWriteAnyDatabase", db: "admin" },
              { role: "dbAdminAnyDatabase", db: "admin" },
              { role: "clusterAdmin", db: "admin" }
           ]
})
exit
BLK


## Enable Authorization

sudo cat << EOB >> /etc/mongod.conf
#security:
security:
    authorization: "enabled"
EOB

echo "-------------------------- RESTARTED MONGOD --------------------------"
sudo systemctl restart mongod
