from fabric.api import *
from fabric.contrib.project import rsync_project

def apply():
    rsync_project(remote_dir='/usr/local/puppet', local_dir='.', extra_opts='--delete')
    sudo('puppet apply --modulepath /usr/local/puppet/modules /usr/local/puppet/manifests/site.pp')

def setup_client():
    sudo('hostname staging.magfest.net') # TODO dont hardcode
    sudo('apt-get update')
    sudo('apt-get -y install puppet')
    sudo('mkdir -p /usr/local/puppet')
    sudo('chown -R %s /usr/local/puppet' % env.user)
