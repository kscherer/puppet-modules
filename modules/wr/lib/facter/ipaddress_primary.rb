Facter.add("ipaddress_primary") do
  setcode do
    if Facter.value('ipaddress_eth0')
      Facter.value('ipaddress_eth0')
    elsif Facter.value('ipaddress_em1')
      Facter.value('ipaddress_em1')
    elsif Facter.value('ipaddress_em1_105')
      Facter.value('ipaddress_em1_105')
    else
      Facter.value('ipaddress')
    end
  end
end
