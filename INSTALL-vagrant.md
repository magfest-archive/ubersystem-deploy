
Windows instructions
=====================

If you're on Linux/etc the process will be similar.

## What you'll need
* [Git](http://git-scm.com/) to check out this repo and to provide SSH.
* [TortoiseGit](https://code.google.com/p/tortoisegit/) or [GitHub for Windows](https://windows.github.com/) to use as an interface for Git. You can also use any other git tool you like, or simply use the command line.
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads) for running your development VM.
* [Vagrant](http://www.vagrantup.com/downloads.html) itself.


Getting started with Vagrant
===============

(Windows instructions, though linux/mac should be identical)

0) Launch a DOS prompt in administrator mode.
Press the Start Menu, type in 'command prompt', and RIGHT CLICK, Run As Administrator

Change your directory to where you want the code to live on your machine.

```
cd path\you\want
```

1) Clone this repository somewhere like so:
```
git clone https://github.com/magfest/ubersystem-deploy/ 
```

2) Setup the config file that tells our deploy scripts where to look for various things.
```
cd ubersystem-deploy/puppet/
cp fabric_settings.example.ini fabric_settings.ini
cd ..
```

Optional: edit fabric_settings.ini in your favorite text editor if you need to. (first time users, you won't need to)

3) Bring up the Vagrant machine. Vagrant will run a new copy of Ubuntu as a virtual machine on your local computer.
```
vagrant up
```

4) then, SSH into your new machine by running
```
vagrant ssh
```

5) once in via SSH, you can now start the automated installer:
```
cd ~/uber/puppet/
./setup_vagrant_control_server.sh
```

6) In about 35 minutes (vagrant shared folders are super-slow on windows) you should have a fully functional ubersystem deployment accessible at: 
```
http://localhost:8000/uber/
```

7) IMPORTANT: completely log out of your SSH session and log back in again (needed for some python startup scripts to kick in)

8) Add a user to ubersystem so you can login. From your bash prompt, type:

```bash
sep insert_admin
```

Now you can visit 
```
http://localhost:8000/uber/
```
This account, by default, has a login of "magfest@example.com" and the password "magfest".

9) Everything's installed! For more info on how to actually code and make changes, see: [Developer Docs](DEVELOPING.md)


Vagrant Troubleshooting:
==========================

1. Shared folders are very slow on Windows. Don't be surprised that things run a bit slower.

2. You probably should use the virtualbox application to increase the CPU and Memory size of the image to make it run smoother.  4CPU and 4GB of mem is a good start.

3. If VirtualBox hangs on startup with a message about "Clearing port forwarding", it's misleading and probably having a silent issue with the shared folder mount (https://github.com/mitchellh/vagrant/issues/3139)  A workaround for this is to install Powershell v3, which seems to fix it. http://www.microsoft.com/en-us/download/details.aspx?id=3459
