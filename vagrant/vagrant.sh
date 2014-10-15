#!/bin/bash

# there is a bug in python -m venv which doesnt obey --copies (i.e. don't do any symlinks)
# I have submitted this to CPython for inclusion but for now, patch the installed python file.
# (we can't use symlinks with SMB shares)
sudo patch /usr/lib/python3.4/venv/__init__.py < /home/vagrant/uber/vagrant/venv-symlink-fix.patch
