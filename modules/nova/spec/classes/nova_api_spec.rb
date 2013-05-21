require 'spec_helper'

describe 'nova::api' do

  let :pre_condition do
    'include nova'
  end

  let :params do
    {:admin_password => 'passw0rd'}
  end

  describe 'on debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end
    it { should contain_service('nova-api').with(
      'name'      => 'nova-api',
      'ensure'    => 'stopped',
      'hasstatus' => 'true',
      'enable'    => false
    )}
    it { should contain_package('nova-api').with(
      'name'   => 'nova-api',
      'ensure' => 'present',
      'notify' => 'Service[nova-api]'
    ) }
    describe 'with enabled as true' do
      let :params do
        {:admin_password => 'passw0rd', :enabled => true}
      end
    it { should contain_service('nova-api').with(
      'name'      => 'nova-api',
      'ensure'    => 'running',
      'hasstatus' => 'true',
      'enable'    => true
    )}
    end
    describe 'with package version' do
      let :params do
        {:admin_password => 'passw0rd', :ensure_package => '2012.1-2'}
      end
      it { should contain_package('nova-api').with(
        'ensure' => '2012.1-2'
      )}
    end
    describe 'with defaults' do
      it 'should use default params for api-paste.init' do
        should contain_nova_paste_api_ini(
         'filter:authtoken/auth_host').with_value('127.0.0.1')
        should contain_nova_paste_api_ini(
          'filter:authtoken/auth_port').with_value('35357')
        should contain_nova_paste_api_ini(
          'filter:authtoken/auth_protocol').with_value('http')
        should contain_nova_paste_api_ini(
          'filter:authtoken/admin_tenant_name').with_value('services')
        should contain_nova_paste_api_ini(
          'filter:authtoken/admin_user').with_value('nova')
        should contain_nova_paste_api_ini(
          'filter:authtoken/admin_password').with_value('passw0rd')
      end
      it { should contain_nova_config('DEFAULT/ec2_listen').with('value' => '0.0.0.0') }
      it { should contain_nova_config('DEFAULT/osapi_compute_listen').with('value' => '0.0.0.0') }
      it { should contain_nova_config('DEFAULT/metadata_listen').with('value' => '0.0.0.0') }
      it { should contain_nova_config('DEFAULT/osapi_volume_listen').with('value' => '0.0.0.0') }
    end
    describe 'with params' do
      let :facts do
        {
          :osfamily          => 'RedHat',
          :processorcount    => 5
        }
      end
      let :params do
        {
          :auth_strategy     => 'foo',
          :auth_host         => '10.0.0.1',
          :auth_port         => 1234,
          :auth_protocol     => 'https',
          :admin_tenant_name => 'service2',
          :admin_user        => 'nova2',
          :admin_password    => 'passw0rd2',
          :api_bind_address  => '192.168.56.210',
          :metadata_listen   => '127.0.0.1',
          :volume_api_class  => 'nova.volume.cinder.API'
        }
      end
      it 'should use default params for api-paste.init' do
        should contain_nova_paste_api_ini(
         'filter:authtoken/auth_host').with_value('10.0.0.1')
        should contain_nova_paste_api_ini(
          'filter:authtoken/auth_port').with_value('1234')
        should contain_nova_paste_api_ini(
          'filter:authtoken/auth_protocol').with_value('https')
        should contain_nova_paste_api_ini(
          'filter:authtoken/admin_tenant_name').with_value('service2')
        should contain_nova_paste_api_ini(
          'filter:authtoken/admin_user').with_value('nova2')
        should contain_nova_paste_api_ini(
          'filter:authtoken/admin_password').with_value('passw0rd2')
      end
      it { should contain_nova_config('DEFAULT/ec2_listen').with('value' => '192.168.56.210') }
      it { should contain_nova_config('DEFAULT/osapi_compute_listen').with('value' => '192.168.56.210') }
      it { should contain_nova_config('DEFAULT/metadata_listen').with('value' => '127.0.0.1') }
      it { should contain_nova_config('DEFAULT/osapi_volume_listen').with('value' => '192.168.56.210') }
      it { should contain_nova_config('DEFAULT/osapi_compute_workers').with('value' => '5') }
    end
  end
  describe 'on rhel' do
    let :facts do
      { :osfamily => 'RedHat' }
    end
    it { should contain_service('nova-api').with(
      'name'    => 'openstack-nova-api',
      'ensure'  => 'stopped',
      'enable'  => false
    )}
    it { should contain_package('nova-api').with_name('openstack-nova-api') }
  end
end