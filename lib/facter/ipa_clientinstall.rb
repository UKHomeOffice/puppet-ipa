# Fact: ipa_clientinstall
#
# Purpose: Is to check to see whether ipa_client was run successfully
#
## ipa_clientinstall.rb
## Facts related to IPA
##

Facter.add("ipa_clientinstall") do
  setcode do
    ENV['TERM'] = ''
    result = "false"
    confine  :osfamily => "RedHat"
    install = system("/usr/bin/pythond -c 'import os,sys,ipapython.sysrestore; sys.exit(0 if ipapython.sysrestore.FileStore(\"/var/lib/ipa-client/sysrestore\").has_files() else 1)'>/dev/null 2>&1")
    if ! install.nil? and install
      result = "true"
    end
    result
  end
end

