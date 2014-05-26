# Fact: Cfkey
#
# Purpose: Return the public key(s) for CFengine.
#
# Resolution:
#   Tries each file of standard localhost.pub & cfkey.pub locations,
#   checks if they appear to be a public key, and then join them all together.
#
# Caveats:
#

## Cfkey.rb
## Facts related to cfengine
##

Facter.add(:Cfkey) do
  setcode do
    confine  :osfamily => "RedHat"
    value = nil
    SSSD_CONF='/etc/sssd/sssd.conf'
    if FileTest.file?(SSSD_CONF) and FileSize.file?(SSSD_CONF) > 0
      true
    else 
      false
    end
  end
end
