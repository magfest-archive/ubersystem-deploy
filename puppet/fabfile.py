from fabric.api import *
from fabric.contrib.project import rsync_project
from fabric.contrib.files import exists
from os.path import expanduser
import subprocess

home_dir = expanduser("~")

puppet_dir = '/usr/local/puppet'
puppet_conf = puppet_dir+'/puppet.conf'
hiera_conf = puppet_dir+'/hiera/hiera.yaml'
node_dir = puppet_dir+'/hiera/nodes'
manifest_to_run = puppet_dir+'/manifests/site.pp'
modules_path = puppet_dir+'/modules'

rsync_opts = '--delete -L --exclude=.git'

def restart_uber_service():
    sudo('supervisorctl restart all')

def stop_uber_service():
    sudo('supervisorctl stop all')

def start_uber_service():
    sudo('supervisorctl start all')

def set_remote_hostname():
    sudo('hostname ' + env.host)

def sync():
    # 1st sync everything but the nodes dir
    rsync_project(
            remote_dir=puppet_dir, 
            local_dir='.', 
            extra_opts=rsync_opts + ' --exclude=hiera/nodes'
    )

    sudo('rm -rf ' + node_dir)
    sudo('mkdir -p ' +node_dir)

    # now sync just the hiera node we're looking at
    # (we don't want to sync them all because these node files contain secrets)
    rsync_project(
            remote_dir=node_dir,
            local_dir='./hiera/nodes/' + env.host + '.yaml',
            extra_opts=rsync_opts
    )
    rsync_project(
            remote_dir=node_dir+'/secret/',
            local_dir='./hiera/nodes/secret/' + env.host + '.yaml',
            extra_opts=rsync_opts
    )

def apply(dry_run='no'):
    execute(set_remote_hostname)
    execute(sync)

    # copy a template of the puppet.conf file, add the line to it
    # that we need to run hiera correctly
    sudo('cp -f '+puppet_dir+'/puppet.conf.template '+puppet_conf)
    sudo('echo -en "[main]\nhiera_config='+hiera_conf+'" >> '+puppet_conf)

    cmdline = " --verbose --debug "
    if dry_run == 'yes':
        cmdline += " --noop "

    sudo(   "puppet apply "
            " --config "+puppet_conf+" "
            " --modulepath "+modules_path+" "
            " "+cmdline+" "
            " "+manifest_to_run+" "
            )

    # TODO: after 'puppet apply', delete the node config since it contains secret info

def do_security_updates():
    sudo('apt-get update')
    sudo('apt-get -y upgrade')

# install just enough to get puppet going
def install_initial_packages():
    sudo('apt-get update')
    sudo('apt-get -y install puppet ruby')
    sudo('gem install deep_merge')
    sudo('mkdir -p ' + puppet_dir)
    sudo('chown -R ' + env.user + ' ' + puppet_dir)

def get_host_ip(hostname):
    # this ONLY uses DNS. no /etc/hosts
    # ip = subprocess.check_output(['/usr/bin/dig', '+short', hostname])

    # this uses /etc/hosts first then DNS
    ip = ""
    output = subprocess.check_output(['/usr/bin/getent', 'hosts', hostname])
    if len(output) > 0:
        ip = output.split(" ")[0]
    return ip

# somewhat optional, but if we don't do this, it will prompt us yes/no
# for acceptin the key for a new server, which we don't want if we're
# fully automated.  or if this is a rebuild, the keys will mismatch
# and it will stop.  
#
# ONLY DO THIS ON SERVER INIT. DO NOT DO THIS EACH TIME WHICH WILL DEFEAT
# THE SECURITY MEASURES.
def register_remote_ssh_keys():
    ssh_dir = home_dir + "/.ssh/"
    known_hosts = ssh_dir + "known_hosts"
    # remove and re-add the new server's SSH key
    ip_of_host = get_host_ip(env.host)
    print("ip is " + ip_of_host)
    local('ssh-keygen -R ' + env.host)
    local('ssh-keygen -R ' + ip_of_host)
    local('ssh-keyscan -H ' + env.host + ' >> ' + known_hosts)
    local('ssh-keyscan -H ' + ip_of_host + ' >> ' + known_hosts)

def reboot_if_updates_needed():
    if exists('/var/run/reboot-required'):
        reboot(120) # waits for 2 minutes for it to reboot

def apply_new_server():
    execute(bootstrap_new_server)
    execute(apply)

def bootstrap_new_server():
    execute(register_remote_ssh_keys)
    execute(set_remote_hostname)
    execute(do_security_updates)
    execute(install_initial_packages)
    execute(reboot_if_updates_needed)

def test():
    print("TEST")
    print("full hoststring = "+env.host_string)
    print("Executing on %(host)s as %(user)s" % env)
    print("port = " + env.port)
    print("ip_of_host = "+get_host_ip(env.host))
    print("remotely exec'ing: 'uname -a'")
    sudo("uname -a")
