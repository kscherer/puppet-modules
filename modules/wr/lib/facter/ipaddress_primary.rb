# from https://github.com/panaman/puppet-hostint/blob/master/lib/facter/hostint.rb
Facter.add("ipaddress_primary") do
  confine :kernel => %w{Linux Darwin FreeBSD}
  if ktype == 'FreeBSD'
    setcode do
      int = Facter::Util::Resolution.exec("netstat -f inet -rn | awk '$1==\"default\" { print $6 }'")
      Facter.value("ipaddress_#{int}")
    end
  elsif ktype == 'Darwin'
    setcode do
      int = Facter::Util::Resolution.exec("netstat -f inet -rn | awk '$1==\"default\" { print $6 }'")
      Facter.value("ipaddress_#{int}")
    end
  elsif ktype == 'Linux'
    setcode do
      int = Facter::Util::Resolution.exec("ip route | grep default | awk '{print $5}'")
      Facter.value("ipaddress_#{int}")
    end
  end
end
