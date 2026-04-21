#!/bin/bash
# 1. Update and install dependencies
sudo yum update -y
sudo yum install -y nodejs git

# 2. Setup the application
cd /home/ec2-user
git clone https://github.com/James/timpay-api.git
cd timpay-api
npm install

# 3. Inject the DB Endpoint into environment variables
echo "DB_HOST=${db_endpoint}" >> .env
echo "PORT=3000" >> .env

# 4. Start the app with PM2 to ensure it restarts on crash
sudo npm install pm2 -g
pm2 start index.js --name "timpay-api"
pm2 save
pm2 startup