inventory do
     format "setup_blade_network %s %s %s %s"
 
     fields { [ facts["macaddress_eth0"], identity, facts["ipaddress"], facts["ipaddress_eth2"] ] }
end

