from fabric.api import *
from fabric.contrib.project import rsync_project

puppet_dir = '/usr/local/puppet'
puppet_conf = puppet_dir+'/puppet.conf'
hiera_conf = puppet_dir+'/hiera/hiera.yaml'
manifest_to_run = puppet_dir+'/manifests/site.pp'
modules_path = puppet_dir+'/modules'

def apply():
    execute(sync)

    # copy a template of the puppet.conf file, add the line to it
    # that we need to run hiera correctly
    sudo('cp -f '+puppet_dir+'/puppet.conf.template '+puppet_conf)
    sudo('echo -en "[main]\nhiera_config='+hiera_conf+'" >> '+puppet_conf)

    sudo(   "puppet apply "
            "--config "+puppet_conf+" "
            "--modulepath "+modules_path+" "
            " "+manifest_to_run+" "
            )

def sync():
    rsync_project(remote_dir=puppet_dir, local_dir='.', extra_opts='--delete')


def bootstrap_new_server():
    sudo('hostname ' + env.host_string)
    sudo('apt-get update')
    sudo('apt-get -y install puppet')
    sudo('mkdir -p ' + puppet_dir)
    sudo('chown -R %s ' + puppet_dir + '' % env.user)
