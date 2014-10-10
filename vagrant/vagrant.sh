#!/bin/bash

# there is a bug in python -m venv which doesnt obey --copies (i.e. don't do any symlinks)
# I have submitted this to CPython for inclusion but for now, patch the installed python file.
# (we can't use symlinks with SMB shares)
sudo patch /usr/lib/python3.4/venv/__init__.py < /home/vagrant/uber/vagrant/venv-symlink-fix.patch

# copy everything over here so it's on the native disk and not in our shared folder, work only out of that.
# this is to get around virtualbox's HORRIBLE slow drive performance.
# later on we'll share this with either NFS or SMB back to the host OS
sudo cp -r /home/vagrant/uber /usr/local/uber
sudo chown -R vagrant.vagrant /usr/local/uber

# . puppet/setup_control_server.sh