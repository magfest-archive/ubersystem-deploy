#!/bin/bash

# dictionary stuff needed for the test DB code to have words to pull from
sudo apt-get update -y
sudo apt-get install -y wamerican language-pack-id apache2-utils
sudo locale-gen en_US en_US.UTF-8 hu_HU hu_HU.UTF-8
sudo dpkg-reconfigure locales

# Enable dynamic swap space to prevent out of memory crashes
sudo apt-get install -y swapspace

# setup our custom bash aliases to make development easy
cp /home/vagrant/uber/vagrant/bash_aliases /home/vagrant/.bash_aliases
