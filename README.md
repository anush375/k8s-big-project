How to install mongodb 4.4.3 on ubuntu 18.04 (Not related to project)

resource "aws_instance" "mongo_vm" {
  ami                         = var.ami_id
  instance_type               = "t2.large"
  key_name                    = var.key_name
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.mongo_sg_id]
  iam_instance_profile = aws_iam_instance_profile.mongo_admin_profile.name
  user_data = <<EOF
#!/bin/bash
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu1804-4.4.3.tgz
tar -xvzf mongodb-linux-x86_64-ubuntu1804-4.4.3.tgz
sudo mv mongodb-linux-x86_64-ubuntu1804-4.4.3 /usr/local/mongodb

mongod --dbpath /data/db --fork --logpath /var/log/mongod.log
mongod

sudo apt update
sudo apt install -y gnupg
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo apt update
sudo apt install -y mongodb-org=4.4.3 mongodb-org-server=4.4.3 mongodb-org-shell=4.4.3 mongodb-org-mongos=4.4.3 mongodb-org-tools=4.4.3

mongod
sudo systemctl start mongod
sudo systemctl enable mongod
sudo systemctl status mongod

mongod --version

sudo journalctl -u mongod --no-pager | tail -50
cat /var/log/mongodb/mongod.log
ls /tmp/
sudo rm /tmp/mongodb-27017.sock
ls /tmp/
sudo systemctl restart mongod
sudo chown mongodb:mongodb /tmp/mongodb-27017.sock
sudo chmod 777 /tmp/mongodb-27017.sock
sudo systemctl restart mongod
ls /tmp/
sudo chown -R mongodb:mongodb /var/lib/mongodb
sudo chown -R mongodb:mongodb /var/log/mongodb
sudo systemctl restart mongod
sudo systemctl status mongod
EOF
  tags = {
    Name = "mongo-db"
  }
}
