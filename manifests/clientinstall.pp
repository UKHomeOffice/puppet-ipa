# Definition: ipa::clientinstall
#
# Installs an IPA client
define ipa::clientinstall (
  $host         = $name,
  $masterfqdn   = {},
  $domain       = {},
  $realm        = {},
  $adminpw      = {},
  $otp          = {},
  $mkhomedir    = {},
  $ntp          = {},
  $dnsupdates   = {},
  $fixedprimary = false,
) {

  if ! str2bool($::ipa_clientinstall) {
    Exec["client-install-${host}"] ~> Ipa::Flushcache["client-${host}"]
  }

  $mkhomediropt = $mkhomedir ? {
    true    => '--mkhomedir',
    default => ''
  }

  $ntpopt = $ntp ? {
    true    => '',
    default => '--no-ntp'
  }

  $fixedprimaryopt = $fixedprimary ? {
    true    => '--fixed-primary',
    default => ''
  }

  $enablednsupdates = $dnsupdates ? {
    true    => '--enable-dns-updates',
    default => ''
  }

  ## the plugin helps or tries to mitigate against lost of network connectivity
  #  with ipa master.  The logic here is if sssd.conf is not present then 
  #  ipa-client-install failed.  Therefore /etc/ipa/ca.crt must be removed if 
  #  ipa-client-install is to be run again

    $clientinstallcmd = shellquote('/usr/sbin/ipa-client-install',"--server=${masterfqdn}","--hostname=${host}","--domain=${domain}","--realm=${realm}","--password=${otp}",$enablednsupdates,$mkhomediropt,$ntpopt,$fixedprimaryopt,'--unattended')
    $dc = prefix([regsubst($domain,'(\.)',',dc=','G')],'dc=')

  if $ipa::client::sudo {
    Ipa::Configsudo <<| |>> {
      name          => $::fqdn,
      os            => "${::osfamily}${::lsbmajdistrelease}",
      sssd_template => $ipa::client::sssd_template,
    }
    if ! str2bool($::ipa_clientinstall) {
      exec { "client-install-${host}":
	command   => "/bin/echo | rm -f /etc/ipa/ca.crt && ${clientinstallcmd}",
	unless    => shellquote('/bin/bash','-c',"LDAPTLS_REQCERT=never /usr/bin/ldapsearch -LLL -x -H ldaps://${masterfqdn} -D uid=admin,cn=users,cn=accounts,${dc} -b ${dc} -w ${adminpw} fqdn=${host} | /bin/grep ^krbLastPwdChange"),
	timeout   => '0',
	tries     => '5',
	try_sleep => '10',
	# returns   => ['0','1'],
        before    => Ipa::Configsudo[$::fqdn],
	logoutput => 'on_failure'
      }
      ipa::flushcache { "client-${host}": }
    }
  }

  if ! str2bool($::ipa_clientinstall) {
    exec { "client-install-${host}":
      command   => "/bin/echo | rm -f /etc/ipa/ca.crt && ${clientinstallcmd}",
      unless    => shellquote('/bin/bash','-c',"LDAPTLS_REQCERT=never /usr/bin/ldapsearch -LLL -x -H ldaps://${masterfqdn} -D uid=admin,cn=users,cn=accounts,${dc} -b ${dc} -w ${adminpw} fqdn=${host} | /bin/grep ^krbLastPwdChange"),
      timeout   => '0',
      tries     => '5',
      try_sleep => '10',
      # returns   => ['0','1'],
      logoutput => 'on_failure'
    }
    ipa::flushcache { "client-${host}": }
  }
}
