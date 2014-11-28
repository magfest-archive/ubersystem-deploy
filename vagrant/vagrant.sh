#!/bin/bash

# dictionary stuff needed for the test DB code to have words to pull from
sudo apt-get update -y
sudo apt-get install -y wamerican language-pack-id
sudo locale-gen en_US en_US.UTF-8 hu_HU hu_HU.UTF-8
sudo dpkg-reconfigure locales

# there is a bug in python -m venv which doesnt obey --copies (i.e. don't do any symlinks)
# I have submitted this to CPython for inclusion but for now, patch the installed python file.
# (we can't use symlinks with SMB shares)
sudo patch /usr/lib/python3.4/venv/__init__.py < /home/vagrant/uber/vagrant/venv-symlink-fix.patch

# setup our custom bash aliases to make development easy
cp /home/vagrant/uber/vagrant/bash_aliases /home/vagrant/.bash_aliases


# setup the puppet module dir so it symlinks to our repository.
# this is purely a convenience thing so you can type 'puppet module install' without
# having to specify --modulepath
mkdir -p /home/vagrant/.puppet
ln -s /home/vagrant/uber/puppet/modules/ /home/vagrant/.puppet
