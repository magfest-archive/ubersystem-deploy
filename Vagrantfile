# -*- mode: ruby -*-

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "Ubuntu 14.04"
    config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box"

    config.vm.network :forwarded_port, guest: 8282, host: 8282
    config.vm.network :forwarded_port, guest: 80, host: 80
    config.vm.network :forwarded_port, guest: 443, host: 443

    # uncomment to enable SMB filesharing which is WAY faster than
    # Virtualbox's shared folders which are SLOOOOOOOOOOOOOOOOW
    #
    # if Vagrant::Util::Platform.windows?
    #    config.vm.synced_folder ".", "/home/vagrant/uber", type: "smb"
    # else
        config.vm.synced_folder ".", "/home/vagrant/uber"
    # end

    #
    # No good can come from updating plugins.
    # Plus, this makes creating Vagrant instances MUCH faster
    #
    if Vagrant.has_plugin?("vagrant-vbguest")
        config.vbguest.auto_update = false
    end

    #
    # This is the most amazing module ever, it caches anything you download with apt-get!
    # To install it: vagrant plugin install vagrant-cachier
    #
    if Vagrant.has_plugin?("vagrant-cachier")
        # Configure cached packages to be shared between instances of the same base box.
        # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
        config.cache.scope = :box
    end

    config.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 2
    end

    config.vm.provision :shell, :path => "vagrant/vagrant.sh"

    config.vm.provider :virtualbox do |vb|
        # allow symlinks to be created in /home/vagrant/uber
        # modify "home_vagrant_uber" to be different if you change the path.
        # NOTE: requires Vagrant to be run as administrator for this to work.
        vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/home_vagrant_uber", "1"]
    end
end
