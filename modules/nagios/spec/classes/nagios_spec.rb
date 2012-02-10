require "#{File.join(File.dirname(__FILE__),'..','spec_helper')}"

describe 'nagios', :type => :class do
  let (:title) { 'nagios test' }

  describe "server" do
    let(:params) { { } }
    let(:facts) { {:operatingsystem => 'CentOS' } }

    it { should contain_package('nagios').with_ensure('latest') }
    it { should contain_service('nagios').with_ensure('running').with_enable(true) }
    it { should contain_file('/etc/nagios/conf.d/nagios_host.cfg').with_mode('0664') }
  end

end
