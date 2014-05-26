# Fact: ipa_clientinstall
#
# Purpose: Is to check to see whether ipa_client was run successfully
#
# Resolution:
#   Checks to see whether sssd.conf file was installed and whether its size is 
#   is greater than zero.
#
# Caveats:
#   None really apart from these checks not being comprehensize enough

## ipa_clientinstall.rb
## Facts related to IPA
##
SSSD_CONF='/etc/sssd/sssd.conf'

Facter.add(:ipa_clientinstall) do
  setcode do
    confine  :osfamily => "RedHat"
    value = nil
    if FileTest.file?(SSSD_CONF) and File.size(SSSD_CONF) > 0
      true
    else 
      false
    end
  end
end
