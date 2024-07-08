#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

# Change Debian to Stable
#cp /etc/apt/sources.list /etc/apt/sources.list.bak
#cp sources.list /etc/apt/sources.list

# Update packages list and update system
apt update
apt upgrade -y

apt install mc unzip -y

# Install php from repo
apt install wget php php-cgi php-mysqli php-pear php-mbstring libapache2-mod-php php-common php-phpseclib php-mysql php-curl php-imagick php-xml php-zip php-gd php-intl -y

# Install Apache from repo
apt install apache2 curl software-properties-common gnupg2 -y

#Configure php on Apache
a2enmod php7.4
systemctl restart apache2

# Install CertBot from repo
apt install certbot python3-certbot-apache -y

#Backup index.html
mkdir /home/admin/backup/
cp /var/www/html/index.html /home/admin/backup/
chown -R admin:admin /home/admin/backup/
rm /var/www/html/index.html

#Deploy Wordpress
wget -O wwwroot.zip 'https://exolgan.blob.core.windows.net/backupexolgan/wwwroot.zip?sp=r&st=2023-08-08T01:51:49Z&se=2023-09-09T09:51:49Z&spr=https&sv=2022-11-02&sr=b&sig=Vyn5tsvqabbwdEW84Q%2BnFokNzvhJW6exdGHcl2OQHMA%3D'
unzip wwwroot.zip
mv wwwroot/* /var/www/html/
echo 'define('FS_METHOD', 'direct');' | tee -a /var/www/html/wp-config.php
chmod -R 755 /var/www/html/
chown -R www-data:www-data /var/www/html/

systemctl restart apache2

echo "MySQL password for wpadmin user:"
echo "> 8 chars, including numeric, mixed case, and special characters"
read -s MYSQL_WP_ADMIN_USER_PASSWORD
echo

sed -i "s/getenv('DATABASE_HOST')/ls-a156a19c4f03955864d023dc5dfc4856af80b072.cbd34w8rtcxc.us-east-1.rds.amazonaws.com/g" /var/www/html/wp-config.php
sed -i "s/getenv('DATABASE_NAME')/mysqlportalprod/g" /var/www/html/wp-config.php
sed -i "s/getenv('DATABASE_USERNAME')/dbmasteruser/g" /var/www/html/wp-config.php
sed -i "s/getenv('DATABASE_PASSWORD')/${MYSQL_WP_ADMIN_USER_PASSWORD}/g" /var/www/html/wp-config.php





