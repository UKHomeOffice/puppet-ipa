# Fact: ipa_masterinstall
#
# Purpose: Is to check to see whether ipa_server was run successfully
#
# Caveats:
#   None really 

## ipa_masterinstall.rb
## Facts related to IPA
##

Facter.add("ipa_masterinstall") do
  setcode do
    result = "false"
    confine  :osfamily => "RedHat"
    install = Facter::Util::Resolution.exec("/usr/bin/python -c 'import sys,ipapython.sysrestore; sys.exit(0 if ipapython.sysrestore.FileStore(\"/var/lib/ipa/sysrestore > /dev/null 2>&1\").has_files() else 1)' > /dev/null 2>&1")
    unless install.nil?
      "true"
    end
    result 
  end
end

