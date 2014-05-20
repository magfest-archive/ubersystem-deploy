from fabric.api import *
from fabric.contrib.project import rsync_project

puppet_dir = '/usr/local/puppet'
puppet_conf = puppet_dir+'/puppet.conf'
hiera_conf = puppet_dir+'/hiera/hiera.yaml'
node_dir = puppet_dir+'/hiera/nodes'
manifest_to_run = puppet_dir+'/manifests/site.pp'
modules_path = puppet_dir+'/modules'

rsync_opts = '--delete -L --exclude=.git'

def sync():
    # 1st sync everything but the nodes dir
    rsync_project(
            remote_dir=puppet_dir, 
            local_dir='.', 
            extra_opts=rsync_opts + ' --exclude=hiera/nodes'
    )
    
    sudo('mkdir ' +node_dir)

    # now sync just the hiera node we're looking at
    # (we don't want to sync them all because these node files contain secrets)
    rsync_project(
            remote_dir=node_dir,
            local_dir='./hiera/nodes/' + env.host_string + '.yaml',
            extra_opts=rsync_opts
    )

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

    # TODO: delete the node config since it contains secret info

def bootstrap_new_server():
    sudo('hostname ' + env.host_string)
    sudo('apt-get update')
    sudo('apt-get -y install puppet')
    sudo('mkdir -p ' + puppet_dir)
    sudo('chown -R ' + env.user + ' ' + puppet_dir)
