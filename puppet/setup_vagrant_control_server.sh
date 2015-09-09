#!/bin/bash

if [ $# -eq 1 ];
then
	extra_args=":event_name=$1"
fi

sudo apt-get update -y
sudo apt-get install -y fabric vim lynx git tofrodos

fab -u root -H `hostname` bootstrap_vagrant_control_server$extra_args

# if we're running under windows, tell git to ignore file permissions on all git repos
# (since the shared folders wrongly mark EVERYTHING as executable and
# git tries to commit that change wrongly whenever you do a commit)
#
# read up on git's 'core.filemode' for more info
#
# this does mean that windows users can't mark things as executable in git repositories without
# explicitly changing things, which is a drag.
if [ "`facter is_vagrant_windows`" == '1' ];
then
    find /home/vagrant/uber -type d -name '.git' | while read -r FILE
    do
        git config --file "$FILE/config" core.filemode false
    done
fi

echo "Deploy finished.  Please log in and out of bash in order for new bash aliases to work correctly,"
echo "if not, certain commands may not work"