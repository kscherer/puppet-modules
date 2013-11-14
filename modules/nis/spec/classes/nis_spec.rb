require 'puppet'
require 'rspec-puppet'
require 'spec_helper'

describe 'nis', :type => 'class' do

  context "On Ubuntu in Ottawa" do
    let(:node) { 'yow-test.example.com' }
    let :facts do
      {
        :operatingsystem => 'Ubuntu',
        :operatingsystemrelease => '12.04',
      }
    end

    it 'install correct package and service' do
      should contain_package('nis').with( { 'name' => 'nis' } )
      should contain_service('nis').with( { 'name' => 'ypbind' } )
      should contain_service('rpc').with( { 'name' => 'portmap' } )
    end

    it 'should create a yp.conf file' do
      verify_contents(subject, '/etc/yp.conf', [
        'domain swamp server yow-adnis1',
        'domain swamp server yow-adnis2'
      ])
    end
  end

  context "On CetnOS in Alameda" do
    let(:node) { 'ala-test.example.com' }
    let :facts do
      {
        :operatingsystem => 'CentOS',
        :operatingsystemrelease => '5.10',
      }
    end

    it 'install correct package and service' do
      should contain_package('nis').with( { 'name' => 'ypbind' } )
      should contain_service('nis').with( { 'name' => 'ypbind' } )
      should contain_service('rpc').with( { 'name' => 'portmap' } )
    end

    it 'should create a yp.conf file' do
      verify_contents(subject, '/etc/yp.conf', [
        'domain swamp server ala-adnis1',
        'domain swamp server ala-adnis2'
      ])
    end
  end

  context "On Ubuntu 10.04 in Bejing" do
    let(:node) { 'pek-test.example.com' }
    let :facts do
      {
        :operatingsystem => 'Ubuntu',
        :operatingsystemrelease => '10.04',
      }
    end

    it 'install correct package and service' do
      should contain_package('nis').with( { 'name' => 'nis' } )
      should contain_service('nis').with( { 'name' => 'nis' } )
      should contain_service('rpc').with( { 'name' => 'portmap' } )
    end

    it 'should create a yp.conf file' do
      verify_contents(subject, '/etc/yp.conf', [
        'domain swamp server 128.224.160.17',
      ])
    end
  end

end
