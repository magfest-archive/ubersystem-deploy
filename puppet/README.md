What is this?
=============

These is a Puppet configuration for getting an ubersystem server or 
vagrant installation up and running from scratch.

How to provision a new uber server
==================================
First, download this repository on an existing server, which will serve
as the master server.

Make a new linux server(s) (called the client server) and setup just enough to get SSH going.  We recommend Ubuntu 14.04 x64 since that's what we test with.

In these examples, change 'new-server.net' to whatever the hostname is of your
new server.

If you don't have one already, create an SSH secret key. (You can check, if you have a file named ~/.ssh/id_rsa.pub you can skip this step)
```
ssh-keygen -t rsa -C "your_email@whatever.com"
```

Copy this SSH key to the new client server:
```
scp ~/.ssh/id_rsa.pub root@new-server.net:~/.ssh/authorized_keys
```

Create a new configuration for your new server.  For now, we'll make a copy of 
the default config which setups up an ubersystem daemon running out of 
/usr/local/uber.  Change 'new-server' to whatever the hostname of your new 
server is.  Have a look inside this file to see the config settings.
(Note: it's important the filenames be named the same as the hostname)
```
cd puppet/hiera
cp example.yaml nodes/new-server.net.yaml
```

Run this command to get the server ready.
```
fab -u root -H new-server.net bootstrap_new_server
```

Run this command to setup ubersystem, ssh, firewall, etc and everything it needs
```
fab -u root -H new-server.net apply
```

That's it! Now you should be able to browse to:  http://new-server.net:4321/magfest and you should be running your very own uber installation.
