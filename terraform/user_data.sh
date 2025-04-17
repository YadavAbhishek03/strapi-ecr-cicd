#!/bin/bash

# Log the process
exec > >(tee /home/ubuntu/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
set -e

echo "Updating system..."
apt update -y && apt upgrade -y

echo "Installing basic dependencies..."
apt install -y curl gnupg build-essential ca-certificates lsb-release

echo "Installing Node.js (via NodeSource)..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

echo "Verifying Node.js and npm installation..."
node -v || { echo "Node.js not installed properly"; exit 1; }

if ! command -v npm &> /dev/null; then
  echo "npm not found, installing manually..."
  apt install -y npm
fi

npm -v || { echo "npm installation failed"; exit 1; }

echo "Installing yarn and pm2 globally..."
npm install -g yarn pm2

echo "Creating Strapi app directory..."
mkdir -p /home/ubuntu/strapi
cd /home/ubuntu/strapi

chown -R ubuntu:ubuntu /home/ubuntu/strapi

echo "Creating Strapi app (older version, no cloud prompt)..."
CI=true STRAPI_DISABLE_TELEMETRY=true npx create-strapi-app@4.14.5 my-strapi-project --quickstart --no-run

echo "Installing dependencies manually..."
cd my-strapi-project
chown -R ubuntu:ubuntu /home/ubuntu/strapi/my-strapi-project
yarn install

echo "Starting Strapi with PM2..."
pm2 start yarn --name strapi -- develop

echo "Configuring PM2 to auto-start on boot..."
pm2 startup systemd -u ubuntu --hp /home/ubuntu
pm2 save
