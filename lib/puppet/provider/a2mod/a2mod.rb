Puppet::Type.type(:a2mod).provide(:a2mod) do
    desc "Manage Apache 2 modules on Debian and Ubuntu"

    optional_commands :encmd => "a2enmod"
    optional_commands :discmd => "a2dismod"
    optional_commands :apache2ctl => "apache2ctl"

    confine :osfamily => :debian
    defaultfor :operatingsystem => [:debian, :ubuntu]

    def self.instances
      modules = apache2ctl("-M").collect { |line|
        m = line.match(/(\w+)_module \(shared\)$/)
        m[1] if m
      }.compact

      modules.map do |mod|
        new(
          :name     => mod,
          :ensure   => :present,
          :provider => :a2mod
        )
      end
    end

    def create
        encmd resource[:name]
    end

    def destroy
        discmd resource[:name]
    end

    def exists?
      @property_hash[:ensure] != :absent
    end
end
