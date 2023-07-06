#! bin/bash

sudo apt update
sudo apt install apache2 -y


git clone https://github.com/Adarshrnaidu/card-website.git

cp -rf . * /var/www/html