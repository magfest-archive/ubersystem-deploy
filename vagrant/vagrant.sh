#!/bin/bash

# for the test DB to have words in it
sudo apt-get install -y wamerican language-pack-id
sudo locale-gen en_US en_US.UTF-8 hu_HU hu_HU.UTF-8
sudo dpkg-reconfigure locales

# there is a bug in python -m venv which doesnt obey --copies (i.e. don't do any symlinks)
# I have submitted this to CPython for inclusion but for now, patch the installed python file.
# (we can't use symlinks with SMB shares)
sudo patch /usr/lib/python3.4/venv/__init__.py < /home/vagrant/uber/vagrant/venv-symlink-fix.patch

cp /home/vagrant/uber/vagrant/bash_aliases /home/vagrant/.bash_aliases
