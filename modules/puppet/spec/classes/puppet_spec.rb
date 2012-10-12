require 'spec_helper'

describe 'puppet', :type => :class do

  describe "agent with running service" do
    let(:params) { { :agent => true } }
    let(:facts) { { :operatingsystem => 'Ubuntu', :rubyversion => '1.8.7' } }

    it { should contain_package('puppet').with_ensure('present').with_provider('aptitude') }
    it { should contain_service('puppet').with_ensure('running').with_enable(true) }
    it { should contain_concat('/etc/puppet/puppet.conf').with_mode('0644') }
    it { should contain_file('/etc/puppet').with_ensure('directory') }
    it { should contain_concat('/etc/puppet/puppet.conf') }
        # .with_notify('Service[puppet]')\
        # .with_require('Package[puppet]') }
  end

  describe "agent with disabled service" do
    let(:params) { { :agent => true, :puppet_agent_service_enable => false } }
    let(:facts) { { :operatingsystem => 'CentOS', :rubyversion => '1.8.7' } }

    it { should contain_package('puppet').with_ensure('present').with_provider('yum') }
    it { should contain_service('puppet').with_ensure('stopped').with_enable(false) }
    it { should contain_concat('/etc/puppet/puppet.conf').with_mode('0644') }
    it { should contain_file('/etc/puppet').with_ensure('directory') }
    it { should contain_concat('/etc/puppet/puppet.conf') }
        # .without_notify('Service[puppet]')\
        # .with_require('Package[puppet]') }
  end

  describe "agent gem with running service" do
    let(:params) { { :agent => true, :package_provider => 'gem' } }
    let(:facts) { { :operatingsystem => 'CentOS', :rubyversion => '1.8.7' } }

    it { should contain_package('puppet').with_ensure('present').with_provider('gem') }
    it { should contain_exec('puppet_agent_start') }
    it { should contain_concat('/etc/puppet/puppet.conf').with_mode('0644') }
    it { should contain_file('/etc/puppet').with_ensure('directory') }
    it { should contain_concat('/etc/puppet/puppet.conf') }
        # .with_notify('Exec[puppet_agent_start]')\
        # .with_require('Package[puppet]') }
  end

  describe "agent uninstalled" do
    let(:params) { { :agent => true, :puppet_agent_ensure => 'absent' } }
    let(:facts) { { :operatingsystem => 'CentOS', :rubyversion => '1.8.7' } }

    it { should contain_package('puppet').with_ensure('absent') }
    it { should_not contain_service('puppet') }
    it { should_not contain_exec('puppet_agent_start') }
    it { should_not contain_concat('/etc/puppet/puppet.conf') }
  end

  describe "agent and master installed" do
    let(:params) { { :agent => true, :master => true } }
    let(:facts) { { :operatingsystem => 'CentOS', :rubyversion => '1.8.7' } }

    it { should contain_package('puppet').with_ensure('present').with_provider('yum') }
    it { should contain_package('puppet-server').with_ensure('present').with_provider('yum') }
    it { should contain_service('puppet') }
    it { should contain_service('puppetmaster') }
    it { should contain_concat('/etc/puppet/puppet.conf') }
        # .with_notify(['Service[puppetmaster]','Service[puppet]'])\
        # .with_require(['Package[puppet-server]','Package[puppet]']) }
  end

  # describe "only master installed with passenger gem" do
  #   let(:params) { { :agent => true, :puppet_agent_ensure => 'absent',
  #       :master => true, :puppet_passenger => true } }
  #   let(:facts) { {:operatingsystem => 'CentOS', :fqdn => "puppet.test.com",
  #                  :rubyversion = '1.8.7' } }

  #   it { should contain_package('puppet').with_ensure('absent') }
  #   it { should contain_package('puppet-server').with_ensure('present').with_provider('yum') }
  #   it { should contain_package('passenger').with_ensure('2.2.11').with_provider('gem') }
  #   it { should_not contain_service('puppet') }
  #   it { should_not contain_service('puppetmaster') }
  #   it { should contain_apache__vhost('puppet-puppet.test.com') }
  #   it { should contain_exec('compile-passenger') }
  #   it { should contain_concat('/etc/puppet/puppet.conf')\
  #       .with_require('Package[puppet-server]')\
  #       .with_notify('Service[httpd]')\
  #   }
  # end

  # describe "only master installed with passenger package" do
  #   let(:params) { { :agent => true, :puppet_agent_ensure => 'absent',
  #       :master => true, :puppet_passenger => true, :passenger_provider => 'yum',
  #       :passenger_package => 'mod_passenger', :passenger_ensure => 'latest' } }
  #   let(:facts) { {:operatingsystem => 'CentOS', :fqdn => "puppet.test.com",
  #                  :rubyversion = '1.8.7' } }

  #   it { should contain_package('puppet').with_ensure('absent') }
  #   it { should contain_package('puppet-server').with_ensure('present').with_provider('yum') }
  #   it { should contain_package('passenger').with_ensure('latest').with_provider('yum') }
  #   it { should_not contain_service('puppet') }
  #   it { should_not contain_service('puppetmaster') }
  #   it { should contain_apache__vhost('puppet-puppet.test.com').with_port('8140') }
  #   it { should_not contain_exec('compile-passenger') }
  # end

  # describe "only master installed with storeconfigs" do
  #   let(:params) { { :agent => true, :puppet_agent_ensure => 'absent',
  #       :master => true, :storeconfigs => true } }
  #   let(:facts) { {:operatingsystem => 'CentOS', :fqdn => "puppet.test.com",
  #                  :rubyversion = '1.8.7' } }

  #   it { should contain_package('puppet').with_ensure('absent') }
  #   it { should contain_package('puppet-server').with_ensure('present').with_provider('yum') }
  #   it { should contain_package('mysql-client').with_ensure('installed') }
  #   it { should contain_package('mysql-server').with_ensure('present') }
  #   it { should contain_package('ruby-mysql').with_ensure('installed').with_provider('yum') }
  #   it { should contain_package('activerecord').with_ensure('installed').with_provider('gem') }
  #   it { should_not contain_service('puppet') }
  #   it { should contain_service('puppetmaster') }
  #   it { should contain_mysql__db('puppet').with_host('localhost') }
  #   it { should_not contain_apache__vhost('puppet-puppet.test.com') }
  # end

  # describe "master and dashboard" do
  #   let(:params) { { :agent => true, :puppet_agent_ensure => 'absent',
  #       :master => true, :dashboard => true } }
  #   let(:facts) { {:operatingsystem => 'CentOS', :fqdn => "puppet.test.com" } }

  #   it { should contain_package('puppet').with_ensure('absent') }
  #   it { should contain_package('puppet-server').with_ensure('present').with_provider('yum') }
  #   it { should contain_package('puppet-dashboard').with_ensure('present') }
  #   it { should contain_package('mysql-client').with_ensure('installed') }
  #   it { should contain_package('mysql-server').with_ensure('present') }
  #   it { should contain_package('ruby-mysql').with_ensure('installed').with_provider('yum') }
  #   it { should_not contain_service('puppet') }
  #   it { should contain_service('puppetmaster') }
  #   it { should contain_service('puppet-dashboard') }
  #   it { should contain_mysql__db('dashboard_production') }
  #   it { should_not contain_apache__vhost('puppet-puppet.test.com') }
  # end

  # describe "master and dashboard with passenger package" do
  #   let(:params) { { :agent => true, :puppet_agent_ensure => 'absent',
  #       :master => true, :puppet_passenger => true, :passenger_provider => 'yum',
  #       :passenger_package => 'mod_passenger', :passenger_ensure => 'latest',
  #       :dashboard => true, :dashboard_passenger => true } }
  #   let(:facts) { {:operatingsystem => 'CentOS', :fqdn => "puppet.test.com" } }

  #   it { should contain_package('puppet').with_ensure('absent') }
  #   it { should contain_package('puppet-server').with_ensure('present').with_provider('yum') }
  #   it { should contain_package('passenger').with_ensure('latest').with_provider('yum') }
  #   it { should_not contain_service('puppet') }
  #   it { should_not contain_service('puppetmaster') }
  #   it { should contain_apache__vhost('puppet-puppet.test.com').with_port('8140') }
  #   it { should_not contain_exec('compile-passenger') }
  #   it { should contain_package('mysql-client').with_ensure('installed') }
  #   it { should contain_package('mysql-server').with_ensure('present') }
  #   it { should contain_package('ruby-mysql').with_ensure('installed').with_provider('yum') }
  #   it { should_not contain_service('puppet-dashboard') }
  #   it { should contain_mysql__db('dashboard_production') }
  #   it { should contain_apache__vhost('dashboard-puppet.test.com').with_port('8080') }
  # end

  # describe "all dressed" do
  #   let(:params) { { :agent => true, :puppet_agent_ensure => 'present',
  #       :puppet_agent_service_enable => false,
  #       :master => true, :puppet_passenger => true, :passenger_provider => 'yum',
  #       :passenger_package => 'mod_passenger', :passenger_ensure => 'latest',
  #       :dashboard => true, :dashboard_passenger => true, :storeconfigs => true,
  #       :activerecord_provider => 'yum', :activerecord_package => 'rubygem-activerecord',
  #       :activerecord_ensure => '3.0.11-1' } }
  #   let(:facts) { {:operatingsystem => 'CentOS', :fqdn => "puppet.test.com" } }

  #   it { should contain_package('puppet').with_ensure('present') }
  #   it { should contain_package('puppet-server').with_ensure('present').with_provider('yum') }
  #   it { should contain_package('passenger').with_ensure('latest').with_provider('yum') }
  #   it { should contain_service('puppet').with_ensure('stopped') }
  #   it { should_not contain_service('puppetmaster') }
  #   it { should contain_apache__vhost('puppet-puppet.test.com').with_port('8140') }
  #   it { should_not contain_exec('compile-passenger') }
  #   it { should contain_package('mysql-client').with_ensure('installed') }
  #   it { should contain_package('mysql-server').with_ensure('present') }
  #   it { should contain_package('ruby-mysql').with_ensure('installed').with_provider('yum') }
  #   it { should_not contain_service('puppet-dashboard') }
  #   it { should contain_mysql__db('dashboard_production') }
  #   it { should contain_apache__vhost('dashboard-puppet.test.com').with_port('8080') }
  #   it { should contain_mysql__db('puppet').with_host('localhost') }
  #   it { should contain_package('rubygem-activerecord').with_ensure('3.0.11-1').with_provider('yum') }
  #   it { should_not contain_package('activerecord') }
  # end

  # describe "agent with running service on OpenSuSE" do
  #   let(:params) { { :agent => true } }
  #   let(:facts) { {:operatingsystem => 'OpenSuSE' } }

  #   it { should contain_package('puppet').with_ensure('present').with_provider('zypper') }
  #   it { should contain_service('puppet').with_ensure('running').with_enable(true) }
  #   it { should contain_concat('/etc/puppet/puppet.conf').with_mode('0644') }
  #   it { should contain_file('/etc/puppet').with_ensure('directory') }
  #   it { should contain_concat('/etc/puppet/puppet.conf') }
  #       # .with_notify('Service[puppet]')\
  #       # .with_require('Package[puppet]') }
  # end
end
