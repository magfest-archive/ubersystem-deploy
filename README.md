Ubersystem Deploy Repository
============================

This module is your starting point for setting up ubersystem and working on it.  

It will check out a bunch of git repos and is the basis for both Vagrant setups and also production deployments.

Docs are WIP, more a coming soon. If you need any help here, email code at magfest dot net.


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

6) Then, in about 35 minutes (vagrant shared folders are super-slow on windows) you should have a fully functional ubersystem deployment accessible at http://localhost:8000/uber/


Getting started with a real control server
====================

Use this for production.  A control server controls the puppet deploys on OTHER NODES, not the one it's running on.

1) get this repo on the control server box
```
apt-get install puppet fabric git
cd somewhere
git clone https://github.com/magfest/ubersystem-deploy/ 
cd ubersystem-deploy/
```

2) Setup the config file.  This step is optional if you're just doing Vagrant, but necessary for production.
```
cp puppet/fabric_settings.example.ini puppet/fabric_settings.ini
cd ..
```

edit fabric_settings.ini to your liking.

3) Bootstrap the control server

```
fab -H localhost bootstrap_control_server
```

Control server is now setup!


Deploying uber to a target node
==========

1) make sure you have root SSH login via SSH keys to the target node.  

2) Make sure you have an appropriate hiera YAML file in puppet/nodes/external name as the fully qualified domain name of the target node.  The hostname must resolve.

example: if the target node is named uber.mydomain.com, you want to do the following:

```
cp puppet/hiera/nodes/vagrant-1.yaml puppet/hiera/nodes/external/uber.mydomain.com.yaml
```

3) Do the first-time deploy

```
cd puppet/
./init_node.sh uber.mydomain.com
```

That's it, you are done!

4) from this point on, whenever you want to do a deploy just do the following:

```
cd puppet/
./apply_node.sh uber.mydomain.com
```
