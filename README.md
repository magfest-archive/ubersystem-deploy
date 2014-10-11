Ubersystem Deploy Repository
============================

This module is your starting point for setting up ubersystem and working on it.  

It will check out a bunch of git repos and is the basis for both Vagrant setups and also production deployments.

More documentation is coming soon.


Getting started with Vagrant
===============

(Windows instructions, though linux/mac should be identical)

1) Clone this repository somewhere like so:
```
cd somewhere
git clone https://github.com/magfest/ubersystem-deploy/ 
```

2) Setup the config file.  This step is optional if you're just doing Vagrant, but necessary for production.
```
cd ubersystem-deploy/puppet/
cp fabric_settings.example.ini fabric_settings.ini
```

edit fabric_settings.ini to your liking.

3) AS AN ADMINISTRATOR, open a command prompt
```
vagrant up
```

4) then, SSH into vagrant by running
```
vagrant ssh
```

5) once in via SSH,
```
cd ~/uber/puppet/
./setup_vagrant_control_server.sh
```

6) Then, in about 15 minutes you should have a fully functional ubersystem deployment accessible at http://localhost/uber/
