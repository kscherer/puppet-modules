# Fact: kmod_*
#
# Purpose: Provide facts about loaded and configured modules
#
# Resolution:
#
# Caveats:

require "facter"
require "set"

MODFILE = "/proc/modules"


def get_modules
    return File.readlines(MODFILE).inject(Set.new){|s,l|s << l[/\w+\b/]}
end


Facter.add("kernel_modules") do
    confine :kernel => "Linux"
    setcode do
      if File.file?(MODFILE)
        modules = get_modules
        modules.to_a.join(",")
      else
        modules = ""
      end
    end
end
