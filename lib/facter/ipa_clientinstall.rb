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

Facter.add(:ipa_clientinstall) do
  setcode do
    confine  :osfamily => "RedHat"
    sssd_conf='/etc/sssd/sssd.conf'
    if FileTest.file?(sssd_conf) and File.size(sssd_conf) > 0
      true
    else 
      false
    end
  end
end
