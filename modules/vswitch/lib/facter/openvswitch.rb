# Fact: openvswitch ports
#
# Purpose: On any OS - return info about ovs ports for all bridges
#
# Resolution:
#
# Caveats:

require "facter"
require "set"

VSCTL = "/usr/bin/ovs-vsctl"
OFCTL = "/usr/bin/ovs-ofctl"
DPCTL = "/usr/bin/ovs-dpctl"


module OpenVSwitch
    def self.exec(bin, cmd)
        result = Facter::Util::Resolution.exec(bin + " " + cmd)
        if result
            result = result.split("\n")
        end
        return result
    end

    # vSwitch
    def self.vsctl(cmd)
        return exec(VSCTL, cmd)
    end

    def self.list_br
        return vsctl("list-br")
    end

    def self.list_ports(bridge)
        return vsctl("list-ports " + bridge)
    end

    def self.dpid(bridge)
        return ofctl("show " + bridge)[0].split(" ")[2].split(":")[1]
    end

    # OpenFlow
    def self.ofctl(cmd)
        return exec(OFCTL, cmd)
    end

    def self.of_show(bridge="")
        return ofctl("show " + bridge)
    end

    # Datapath
    def self.dpctl(cmd)
        return exec(DPCTL, cmd)
    end
end


Facter.add("openvswitch_module") do
    setcode do
        modules = Facter.value(:kernel_modules).split(",")
        if modules.include? "openvswitch"
            true
        elsif modules.include? "openvswitch_kmod"
            true
        else
           Facter.debug("\nno kernel_modules availiable! Setting openvswitch module to false\n")
           false
        end
    end
end


if Facter.value(:openvswitch_module) == true && File.exists?(VSCTL)
    bridges = OpenVSwitch.list_br || []

    Facter.add("openvswitch_bridges") do
        setcode do
            bridges.join(",")
        end
    end

    bridges.each do |bridge|
        ports = OpenVSwitch.list_ports(bridge)
        if ports
            Facter.add("openvswitch_ports_#{bridge}") do
                setcode do
                    ports.join(",")
                end
            end
        end

        Facter.add("openvswitch_dpid_#{bridge}") do
            setcode do
                OpenVSwitch.dpid(bridge)
            end
        end
    end
end
