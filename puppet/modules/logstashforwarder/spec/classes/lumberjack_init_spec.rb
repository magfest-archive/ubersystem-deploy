require 'spec_helper'

describe 'logstash-forwarder', :type => 'class' do

  context "On Debian OS" do

    let :facts do {
      :operatingsystem => 'Debian'
    } end

    # init.pp
    it { should contain_class('logstash-forwarder::package') }

  end

  context "On Ubuntu OS" do

    let :facts do {
      :operatingsystem => 'Ubuntu'
    } end

    # init.pp
    it { should contain_class('logstash-forwarder::package') }

  end

  context "On CentOS OS" do

    let :facts do {
      :operatingsystem => 'CentOS'
    } end

    # init.pp
    it { should contain_class('logstash-forwarder::package') }

  end

  context "On RedHat OS" do

    let :facts do {
      :operatingsystem => 'Redhat'
    } end

    # init.pp
    it { should contain_class('logstash-forwarder::package') }

  end

  context "On Fedora OS" do

    let :facts do {
      :operatingsystem => 'Fedora'
    } end

    # init.pp
    it { should contain_class('logstash-forwarder::package') }

  end

  context "On Scientific OS" do

    let :facts do {
        :operatingsystem => 'Scientific'
    } end

    # init.pp
    it { should contain_class('logstash-forwarder::package') }

  end

  context "On Amazon OS" do

    let :facts do {
      :operatingsystem => 'Amazon'
    } end

    # init.pp
    it { should contain_class('logstash-forwarder::package') }

  end

  context "On OracleLinux OS" do

    let :facts do {
      :operatingsystem => 'OracleLinux'
    } end

    # init.pp
    it { should contain_class('logstash-forwarder::package') }

  end

  context "On an unknown OS" do

    let :facts do {
      :operatingsystem => 'Darwin'
    } end

    it { expect { should raise_error(Puppet::Error) } }

  end

end

