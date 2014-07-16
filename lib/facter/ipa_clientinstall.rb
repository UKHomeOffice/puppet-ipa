# Fact: ipa_clientinstall
#
# Purpose: Is to check to see whether ipa_client was run successfully
#
## ipa_clientinstall.rb
## Facts related to IPA
##

Facter.add(:ipa_clientinstall) do
  setcode do
    confine  :osfamily => "RedHat"
    if Facter::Util::Resolution.exec("/usr/bin/python -c 'import sys,ipapython.sysrestore; sys.exit(0 if ipapython.sysrestore.FileStore(\"/var/lib/ipa-client/sysrestore\").has_files() else 1)' > /dev/null 2>&1") 
      "true"
    else 
      "false"
    end
  end
end
