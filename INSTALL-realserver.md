
Getting started with a real control server
====================

Use this for production.  A control server controls the puppet deploys on OTHER NODES, not the one it's running on.  Don't use this for Vagrant

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
