#!/bin/bash

echo " Welcome to laravel site hosting"
echo
sleep 3

cd
sudo apt update

sudo apt install php libapache2-mod-php php-mysql php-xml php-mbstring php-zip php-curl php-bcmath php-json -y
echo "Installing composer..."

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
php -r "unlink('composer-setup.php');"


echo "Enter project name:"
read PROJECT_NAME

echo "Enter domain name to setup:"
read DOMAIN

#database setup
echo "Enter name of your database:"
read DB_DATABASE

echo "Enter database username:"
read DB_USERNAME

echo "Enter database password:"
read DB_PASSWORD

sudo mysql -uroot -proot <<mysql_script
create database $DB_DATABASE;
create user '$DB_USERNAME'@'localhost' identified by '$DB_PASSWORD';
grant all privileges on $DB_DATABASE.* to '$DB_USERNAME'@'localhost';
flush privileges;
mysql_script


echo "Creating Laravel project..."
cd /var/www
sudo composer create-project --prefer-dist laravel/laravel $PROJECT_NAME
# Configure Laravel .env file
echo "Configuring Laravel .env file..."
sudo cp /var/www/$PROJECT_NAME/.env.example /var/www/$PROJECT_NAME/.env
sudo sed -i "s/DB_DATABASE=laravel/DB_DATABASE=${DB_NAME}/" /var/www/$PROJECT_NAME/.env
sudo sed -i "s/DB_USERNAME=root/DB_USERNAME=${DB_USER}/" /var/www/$PROJECT_NAME/.env
sudo sed -i "s/DB_PASSWORD=/DB_PASSWORD=${DB_PASSWORD}/" /var/www/$PROJECT_NAME/.env


# Generate application key
echo "Generating application key..."
cd /var/www/$PROJECT_NAME
sudo php artisan key:generate
APACHE_CONF="/etc/apache2/sites-available/$PROJECT_NAME.conf"

sudo bash -c "cat > $APACHE_CONF << EOL
<VirtualHost *:80>
    ServerName ${DOMAIN}
    DocumentRoot /var/www/${PROJECT_NAME}/public

    <Directory /var/www/${PROJECT_NAME}/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL"



echo "Enabling site and rewrite module..."
sudo a2ensite $PROJECT_NAME.conf
sudo a2enmod rewrite

# Restart Apache
echo "Restarting Apache..."
sudo systemctl restart apache2

echo "Laravel site setup is complete. Add the domain to /etc/hosts file if needed."

