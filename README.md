Ubersystem Deploy Repository
============================

This module is your starting point for setting up ubersystem and working on it.  

It will check out a bunch of git repos and is the basis for both Vagrant setups and also production deployments.

More documentation is coming soon.


Getting started with Vagrant
===============

(Windows instructions, though linux/mac should be identical)

Clone this repository somewhere.

AS AN ADMINISTRATOR, open a command prompt
```
cd ubersystem-deploy
vagrant up
```

then, SSH into vagrant by running
```
vagrant ssh
```

once in via SSH,
```
cd ~/uber/puppet/
./setup_vagrant_control_server.sh
```

Then, in about 15 minutes you should have a fully functional ubersystem deployment accessible at http://localhost/