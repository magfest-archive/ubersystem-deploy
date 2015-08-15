Some info on how to develop.


Supervisord
=============
First, ubersystem by default is running as a process inside a program called Supervisor which runs
uber as a daemon automatically on system start.

For development purposes, you will want to disable this.  Type the following:

```
sudo supervisorctl stop all
```

Now that it's disabled, you'll need to start the server manually

Running the server
===================

To run ubersystem manually, simply type:
```
run_server
```

(it's a bash alias)


Directory structure
==============

Once everything is fully deployed, the folder structure that you can access from the Host OS 
(i.e. your Windows machine or whatever host OS you are using) will look like this:

- ubersystem-deploy/ - this repository
- ubersystem-deploy/sideboard - a repository containing sideboard, 
- ubersystem-deploy/plugins - a folder which contains other repositories which are ubersystem plugins, which includes....
- ubersystem-deploy/plugins/uber - the main ubersystem repository itself, where most of the important code is

- ubersystem-deploy/hiera/nodes - an optional repository containing your organization's specific hiera overrides
- ubersystem-deploy/hiera/nodes/external/secret - an optional repository containing your organization's specific SECRET hiera overrides


How to add to ubersystem's config
====================
(need to flesh this out some more)

Ubersystem when it starts up reads from development.ini which overrides anything in development-defaults.ini and configspeci.ini

You can put new stuff in development.ini by doing the following:
1) modifying the following template:
https://github.com/magfest/ubersystem-puppet/blob/master/templates/uber-development.ini.erb

2) modify the puppet manifest to know about that config:
https://github.com/magfest/ubersystem-puppet/blob/master/manifests/config.pp

3) modify your hiera node to use those template values
https://github.com/magfest/ubersystem-deploy/blob/master/puppet/hiera/common.yaml

For an example, look through those files for the config setting named "organizatin_name" and that's exactly how you implement it.


TODO
====
- add info about setting up test data in the DB
- add info about resetting the db with 'sep reset_uber_db'
- add info about re-deploying config changes with 'puppet/apply_node.sh'
- add info about fabric_settings.ini and the recommended way to setup production environments for other organizations
