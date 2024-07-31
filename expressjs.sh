#!/bin/bash
set -e
set -x
# Update and install necessary packages
sudo apt update
sudo apt install -y curl git nginx

# Install Node.js and npm using NodeSource
curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Create a directory for the Express.js application
echo "Enter your application directory name:"
read application_directory

sudo mkdir -p /var/www/$application_directory

# Change to the application directory
cd /var/www/$application_directory

# Create a new Express.js application
npx express-generator

# Install application dependencies
npm install

# Install PM2 globally
sudo npm install -g pm2

# Start the Express.js application using PM2
echo "Enter the port number to run your application on:"
read port_number

# Start the application with PM2, specifying the port
pm2 start ./bin/www --name $application_directory -- --port $port_number

# Configure PM2 to start on boot
#pm2 startup systemd
pm2 save

# Configure Nginx as a reverse proxy
echo "Enter your domain name (without www):"
read domain_name

sudo bash -c "cat > /etc/nginx/sites-available/$domain_name <<EOF
server {
    listen 80;
    server_name $domain_name www.$domain_name;

    location / {
        proxy_pass http://localhost:$port_number;
        proxy_http_version 1.1;
    }
}
EOF"

# Enable the Nginx configuration and restart the service
sudo ln -s /etc/nginx/sites-available/$domain_name /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# Add entry to /etc/hosts
sudo bash -c "echo '127.0.0.1 $domain_name' >> /etc/hosts"

echo "Express.js application setup and configuration completed successfully."

