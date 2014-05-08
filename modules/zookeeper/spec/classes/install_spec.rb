require 'spec_helper'

describe 'zookeeper::install' do
  shared_examples 'debian-install' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'Debian',
      :lsbdistcodename => codename,
    }}

    it { should contain_package('zookeeper') }
    it { should contain_package('zookeeperd') }
    it { should contain_package('cron') }

    it {
      should contain_cron('zookeeper-cleanup').with({
        'ensure'    => 'present',
        'command'   => '/usr/lib/zookeeper/bin/zkCleanup.sh /var/lib/zookeeper 1',
        'user'      => 'zookeeper',
        'hour'      => '2',
        'minute'      => '42',
      })

    }
  end

  context 'on debian-like system' do
    let(:user) { 'zookeeper' }
    let(:group) { 'zookeeper' }

    let(:params) { {
      :snap_retain_count => 1,
    } }

    it_behaves_like 'debian-install', 'Debian', 'squeeze'
    it_behaves_like 'debian-install', 'Debian', 'wheezy'
    it_behaves_like 'debian-install', 'Ubuntu', 'precise'
  end

  context 'without cron' do
    let(:user) { 'zookeeper' }
    let(:group) { 'zookeeper' }

    let(:params) { {
      :snap_retain_count => 0,
    } }

    it { should contain_package('zookeeper') }
    it { should contain_package('zookeeperd') }
    it { should_not contain_package('cron') }
  end


  context 'removing package' do
    let(:user) { 'zookeeper' }
    let(:group) { 'zookeeper' }

    let(:params) { {
      :ensure => 'absent',
    } }

    it {

      should contain_package('zookeeper').with({
      'ensure'  => 'absent',
      })
    }
    it {
      should contain_package('zookeeperd').with({
      'ensure'  => 'absent',
      })
    }
    it { should_not contain_package('cron') }
  end


end
