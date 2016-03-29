Facter.add("ipaddress_primary") do
  confine :kernel => %w{Linux}
  setcode do
    # tr is needed to handle vlan addresses
    int = Facter::Util::Resolution.exec("ip route | grep default | awk '{print $5}'").tr('.', '_')
    Facter.value("ipaddress_#{int}")
  end
end
