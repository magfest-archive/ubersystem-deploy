from fabric.api import *
from fabric.contrib.project import rsync_project
from fabric.contrib.files import exists
import os, sys
from os.path import expanduser
import subprocess
from datetime import datetime
from ConfigParser import SafeConfigParser, NoOptionError, NoSectionError
import logging


# enable this to get more advanced SSH logging, useful if you're having
# SSH key issues.
# logging.basicConfig(level=logging.DEBUG)


class FabricConfig:
    def __init__(self):
        self.parser = SafeConfigParser()
        self.parser.read('fabric_settings.ini')

        self.git_ubersystem_module_repo = self.read_config('repositories', 'git_ubersystem_module_repo', "https://github.com/magfest/ubersystem-puppet")
        self.git_ubersystem_module_repo_branch = self.read_config('repositories', 'git_ubersystem_module_repo_branch', None)

        self.git_regular_nodes_repo = self.read_config('repositories', 'git_regular_nodes_repo')
        self.git_regular_nodes_repo_branch = self.read_config('repositories', 'git_regular_nodes_repo_branch', None)

        self.git_secret_nodes_repo = self.read_config('repositories', 'git_secret_nodes_repo')
        self.git_secret_nodes_repo_branch = self.read_config('repositories', 'git_secret_nodes_repo_branch', None)

    def read_config(self, section_name, option, default=None):
        try:
            return self.parser.get(section_name, option)
        except NoOptionError:
            return default
        except NoSectionError:
            return default

fabricconfig = FabricConfig()

home_dir = expanduser("~")

puppet_dir = '/usr/local/puppet'
puppet_conf = puppet_dir+'/puppet.conf'
hiera_conf = puppet_dir+'/hiera/hiera.yaml'
node_dir = puppet_dir+'/hiera/nodes/external'
manifest_to_run = puppet_dir+'/manifests/site.pp'
modules_path = puppet_dir+'/modules'

rsync_opts = '--delete -L --exclude=.git'


def read_hosts():
    """
    Reads hosts from sys.stdin line by line, expecting one host per line.

    example: use to run the same command on a bunch of hosts like this:
    cat active-hosts.txt | fab read_hosts do_security_updates
    """
    env.hosts = [line.strip() for line in sys.stdin.readlines() if '#' not in line]


def restart_uber_service():
    sudo('supervisorctl restart all')


def stop_uber_service():
    sudo('supervisorctl stop all')


def start_uber_service():
    sudo('supervisorctl start all')


def set_remote_hostname():
    sudo('hostname ' + env.host)


def backup_db(dbname = 'rams_db', local_backup_dir='~/backup/'):
    backup_filename = "dbbackup-" + env.host + "+" + datetime.now().strftime("%F-%H:%M:%S") + ".sql"
    backups_dir = "/var/db_backups/"
    remote_backup_fullpath = backups_dir + backup_filename

    sudo("mkdir -p " + backups_dir)
    sudo("chown postgres.postgres -R " + backups_dir)
    sudo("chmod 700 " + backups_dir)

    backup_cmd = 'pg_dump ' + dbname + ' -f ' + remote_backup_fullpath
    sudo("su - postgres -c '" + backup_cmd + "'")

    sudo("bzip2 " + remote_backup_fullpath)
    remote_backup_fullpath_zipped = remote_backup_fullpath + ".bz2"

    sudo("chmod 600 -R " + backups_dir + "/*")

    get(remote_path=remote_backup_fullpath_zipped, local_path=local_backup_dir)


def sync_puppet_related_files_to_node():
    # sync everything
    # TODO: SECURITY: we're copying too much data onto the other box about other nodes.
    # really.... we should just use a puppet master for this thing, as it handles all this part for us.
    rsync_project(
        remote_dir=puppet_dir,
        local_dir='.',
        extra_opts=rsync_opts
    )


def puppet_apply(dry_run='no'):
    execute(set_remote_hostname)
    execute(sync_puppet_related_files_to_node)

    # copy a template of the puppet.conf file, add the line to it
    # that we need to run hiera correctly
    sudo('cp -f '+puppet_dir+'/puppet.conf.template '+puppet_conf)
    sudo('echo -en "[main]\nhiera_config='+hiera_conf+'" >> '+puppet_conf)

    cmdline = " --verbose "
    # cmdline += " --debug "
    if dry_run == 'yes':
        cmdline += " --noop "

    sudo(   "puppet apply "
            " --config "+puppet_conf+" "
            " --modulepath "+modules_path+" "
            " "+cmdline+" "
            " "+manifest_to_run+" "
            )

    # TODO: after 'puppet apply', delete the node config since it contains secret info


def run_unit_tests(path='/usr/local/uber/plugins', pytest='/usr/local/uber/env/bin/py.test'):
    """
    Run all unit tests in a given subdirectory.

    If running this against staging or production servers, it's usually a good idea to skip the sideboard tests
    because they actually start up the server and do some slightly weird things.

    This function is kind of a 'best-effort' quick way to run the unit tests, and does not take the place of
    real CI which would do a better job.
    :param path: The path to run the tests in
    """

    sudo('{} {}'.format(pytest, path))


def do_security_updates():
    sudo('apt-get update')
    sudo('apt-get -y upgrade')


# install just enough initial packages to get puppet going.
def install_initial_packages():
    sudo('apt-get update')
    sudo('apt-get -y install puppet ruby tofrodos')
    sudo('gem install deep_merge')
    sudo('mkdir -p ' + puppet_dir)
    sudo('chown -R ' + env.user + ' ' + puppet_dir)


# get the IP of a particular host
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
# for accepting the key for a new server, which we don't want if we're
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

    if os.path.exists(known_hosts):
        print('removing existing keys')
        local('ssh-keygen -R ' + env.host)
        local('ssh-keygen -R ' + ip_of_host)

    local('ssh-keyscan -H ' + env.host + ' >> ' + known_hosts)
    local('ssh-keyscan -H ' + ip_of_host + ' >> ' + known_hosts)


def reboot_if_updates_needed():
    if exists('/var/run/reboot-required'):
        reboot(120) # waits for 2 minutes for it to reboot


# one command to rule them all.  take a brand new newly provisioned virgin box and do everything needed
# to have a full ubersystem deploy applied with puppet
def puppet_apply_new_node(auto_update = True, environment='development', event_name='test'):
    execute(bootstrap_new_node, auto_update, environment=environment, event_name=event_name)
    execute(puppet_apply)


# do all setup tasks to get a node (a server which runs ubersystem) ready to do a 'puppet apply'
def bootstrap_new_node(auto_update = True, environment='development', event_name='test'):
    execute(register_remote_ssh_keys)
    execute(set_remote_hostname)

    if auto_update:
        execute(do_security_updates)

    execute(install_initial_packages)

    execute(setup_extra_node_specific_facter_facts, environment=environment, event_name=event_name)

    if auto_update:
        execute(reboot_if_updates_needed)


def setup_extra_node_specific_facter_facts(environment, event_name):
    sudo("mkdir -p /etc/facter/facts.d/")
    sudo("bash -c 'echo event_name=" + event_name + " > /etc/facter/facts.d/event_name.txt'")
    sudo("bash -c 'echo environment=" + environment + " > /etc/facter/facts.d/environment.txt'")


def local_git_clone(repo_url, checkout_path, branch=None):
    if repo_url and not os.path.exists(checkout_path):
        branch_args = ""
        if branch:
            branch_args = " -b " + branch + " "
        local("git clone " + repo_url + " " + checkout_path + branch_args)


# get a control server (NOT a node) ready to go. a control server runs fabric and puppet, and controls deployment
# of several (usually separate) nodes
def bootstrap_control_server():
    local_git_clone(fabricconfig.git_ubersystem_module_repo, "modules/uber", branch = fabricconfig.git_ubersystem_module_repo_branch)
    local_git_clone(fabricconfig.git_regular_nodes_repo, "hiera/nodes/", branch = fabricconfig.git_regular_nodes_repo_branch)
    local_git_clone(fabricconfig.git_secret_nodes_repo, "hiera/nodes/external/secret", branch = fabricconfig.git_secret_nodes_repo_branch)


def copy_control_server_files():
    generate_ssh_key_control_server_if_non_exists()

    # make it so we can SSH into root@localhost as though it was another node
    print("copying SSH key to local root user")
    local("sudo mkdir -p /root/.ssh/")
    local("sudo cp -f ~/.ssh/id_rsa.pub /root/.ssh/authorized_keys")

    bootstrap_control_server()


def bootstrap_vagrant_control_server(environment='development', event_name='test'):
    copy_control_server_files()
    puppet_apply_new_node(auto_update = False, environment=environment, event_name=event_name)


# generate an ssh key
def generate_ssh_key_control_server_if_non_exists():
    if os.path.exists(home_dir + "/.ssh/id_rsa.pub"):
        return

    local("ssh-keygen -f ~/.ssh/id_rsa -t rsa -C 'root@magfest-vagrant.com' -N '' ")


def print_server_info():
    print("full hoststring = "+env.host_string)
    print("Executing on %(host)s as %(user)s" % env)
    print("port = " + env.port)
    print("ip_of_host = "+get_host_ip(env.host))
    print("remotely exec'ing: 'uname -a'")
    sudo("uname -a")
    print("fact: environment is:")
    sudo("facter environment")
    print("fact: event_name is:")
    sudo("facter event_name")
