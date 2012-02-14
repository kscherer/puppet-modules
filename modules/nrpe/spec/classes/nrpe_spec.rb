require "#{File.join(File.dirname(__FILE__),'..','spec_helper')}"

describe 'nrpe', :type => :class do
  let (:title) { 'nrpe_test' }

  describe "basic" do
    let(:params) { { } }
    let(:facts) { {:operatingsystem => 'CentOS', :osfamily => 'RedHat',
                   :architecture => 'x86_64'} }

    it { should contain_package('nagios-plugins-disk').with_ensure('present') }
    it { should contain_file('check_nx_instance').with_ensure('present') }
    it { should contain_nrpe__command('check_nx_instance').with_command('check_nx_instance.sh') }
    it { should contain_file('/etc/nrpe.d/check_nx_instance.cfg') }
  end
end
