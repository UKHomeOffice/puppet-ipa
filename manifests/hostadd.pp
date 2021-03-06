define ipa::hostadd (
  $host     = $name,
  $otp      = {},
  $desc     = {},
  $clientos = {},
  $clientpf = {},
  $locality = {},
  $location = {},
#  $ip       = {},
) {

  $timestamp = strftime("%a %b %d %Y %r")
  $descinfo = rstrip(join(['Added by IPA Puppet module on',$timestamp,$desc], " "))

  if $::ipa_adminhomedir and is_numeric($::ipa_adminuidnumber) {
    unless $host == undef {
    exec { "hostadd-${host}":
      command   => "/sbin/runuser -l admin -c \'/usr/bin/ipa host-add ${host} --force  --locality=\"${locality}\" --location=\"${location}\" --desc=\"${descinfo}\" --platform=\"${clientpf}\" --os=\"${clientos}\" --password=${otp}\'",
      unless    => "/sbin/runuser -l admin -c \'/usr/bin/ipa host-show ${host} >/dev/null 2>&1\'",
      tries     => '5',
      try_sleep => '10'
    }
    }
  }
}
