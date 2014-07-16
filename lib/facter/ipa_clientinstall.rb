# Fact: ipa_clientinstall
#
# Purpose: Is to check to see whether ipa_client was run successfully
#
## ipa_clientinstall.rb
## Facts related to IPA
##

Facter.add("ipa_clientinstall") do
  setcode do
    result = "false"
    confine  :osfamily => "RedHat"
    install = Facter::Util::Resolution.exec("/usr/bin/python -c 'import sys,ipapython.sysrestore; sys.exit(0 if ipapython.sysrestore.FileStore(\"/var/lib/ipa-client/sysrestore > /dev/null 2>&1\").has_files() else 1)' > /dev/null 2>&1")
    unless install.nil?
      "true"
    end
    result 
  end
end
