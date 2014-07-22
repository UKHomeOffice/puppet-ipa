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
    ENV['TERM'] = ''
    result = "false"
    confine  :osfamily => "RedHat"
    install = system("/usr/bin/python -c 'import os,sys,ipapython.sysrestore; sys.exit(0 if ipapython.sysrestore.FileStore(\"/var/lib/ipa/sysrestore\").has_files() else 1)'>/dev/null 2>&1")
    if ! install.nil? and install
      result = "true"
    end
    result
  end
end

