#!/bin/bash
set -e
set -x
echo "Welcome to Wordpress hosting..."
sudo apt update
sudo apt install -y apache2 mysql-server php php-mysql libapache2-mod-php php-cli wget unzip

# set up mysql database and user
#db_name="wordpress"
#db_user="userOne"
#db_pass="userOne"
#mysql_root_pass="root"
echo "enter domain name of of your choice:"
read domain_name
echo "Enter database name:"
read db_name
echo "Enter database username:"
read db_user
echo "Enter database password:"
read -s db_pass
echo "Enter root passoword:"
read -s mysql_root_pass

sudo mysql -uroot -p"$mysql_root_pass" <<mysql_script
create database $db_name;
create user '$db_user'@'localhost' identified by '$db_pass';
grant all privileges on $db_name.* to '$db_user'@'localhost';
flush privileges;
mysql_script

echo "mysql database and user created."

# download and configure wordpress
cd /tmp
wget https://wordpress.org/latest.zip
unzip latest.zip
mv wordpress ${domain_name}
sudo mv ${domain_name} /var/www/html/

# configure wordpress database settings
cd /var/www/html/${domain_name}
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/$db_name/" wp-config.php
sudo sed -i "s/username_here/$db_user/" wp-config.php
sudo sed -i "s/password_here/$db_pass/" wp-config.php

# set appropriate permissions
sudo chown -R www-data:www-data /var/www/html/${domain_name}
sudo find /var/www/html/{${domain_name}/ -type d -exec chmod 750 {} \;
sudo find /var/www/html/${domain_name}/ -type f -exec chmod 640 {} \;

# enable apache mod_rewrite
sudo a2enmod rewrite
sudo systemctl restart apache2

# create apache configuration file for wordpress
sudo bash -c 'cat > /etc/apache2/sites-available/${domain_name}.conf <<EOF
<virtualhost *:80>
    ServerName ${domain_name}.com
    documentroot /var/www/html/${domain_name}
    <directory /var/www/html/${domain_name}>
        options indexes followsymlinks
        allowoverride all
        require all granted
    </directory>
</virtualhost>
EOF'

# enable the wordpress site and disable the default site
sudo a2ensite ${domain_name}
sudo a2dissite 000-default
sudo systemctl reload apache2

echo "wordpress installed and configured. please complete the setup through the web interface."

