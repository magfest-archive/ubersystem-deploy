
Getting started with a real control server
====================

Use this for actually running this in production.  A control server controls the puppet deploys on OTHER NODES, not the one it's running on.

*IF YOU JUST WANT TO PLAY AROUND WITH UBER, DON'T DO THIS, DO THE SIMPLER VERSION HERE: https://github.com/magfest/simple-rams-deploy*

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

To install ubersystem on a target node (usually a different server from this one)

1) make sure you have root SSH login via SSH keys to the target node.  

2) decide the 'facts' associated with this node.
environment='development' or 'production'
event_name=[whatever you want]. examples: 'classic' for magfest classic.  'prime' for magfest prime

3) Do the first-time deploy like this:

```
cd puppet/
./init_node.sh [your_target_nodes_hostname_here] [your_environment_here] [your_event_name_here]
```

Example, if your target name is myuberserver.myorganization.com, for a 'production' environment deploy for an event named 'coolcon', you'd do:

```
./init_node.sh myuberserver.myorganization.com production coolcon
```

That's it, you are done!

4) from this point on, whenever you want to do a deploy just do the following:

```
cd puppet/
./apply_node.sh uber.mydomain.com
```
