#!/bin/bash
sudo apt-get update -y

# 1. Install Docker & Compose
sudo apt-get install -y docker.io docker-compose-v2
sudo usermod -aG docker ubuntu

# 2. Install Jenkins (Java and Jenkins Repo)
sudo apt-get install -y openjdk-17-jre-headless
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# 3. Install AWS CodeDeploy Agent
sudo apt-get install -y ruby-full wget
cd /home/ubuntu
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto