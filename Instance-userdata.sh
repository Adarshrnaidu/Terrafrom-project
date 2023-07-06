#!/bin/bash

sudo apt update
sudo apt install apache2 -y


sudo git clone https://github.com/Adarshrnaidu/card-website.git
sudo cd card-website
sudo cp -rf * /var/www/html
