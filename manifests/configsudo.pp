# Definition: ipa::configsudo
#
# Configures sudoers in LDAP
define ipa::configsudo (
  $host       = $name,
  $os         = {},
  $sudopw     = {},
  $adminpw    = {},
  $domain     = {},
  $masterfqdn = {},
  $sssd_template = ''
) {

  Augeas["nsswitch-sudoers-${host}"] -> Package <| title == 'libsss_sudo' |> 

  $dc = prefix([regsubst($domain,'(\.)',',dc=','G')],'dc=')

  augeas { "nsswitch-sudoers-${host}":
    context => '/files/etc/nsswitch.conf',
    changes => [
      'set database[. = "sudoers"] sudoers',
      'set database[. = "sudoers"]/service[1] files',
      'set database[. = "sudoers"]/service[2] sss'
    ]
  }

  @package {'libsss_sudo': ensure => 'present'}

  @file {"sssd.conf-${host}":
    ensure => 'present',
    path   => '/etc/sssd/sssd.conf',
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    content => template($sssd_template),
  }

  exec { "setupnisdomain-${host}":
    command => "/bin/nisdomainname ${domain}",
    unless  => "/usr/bin/test $(/bin/nisdomainname) = ${domain}",
  }

#  realize Package['libsss_sudo']
#  realize Service['sssd']

  if $sssd_template and str2bool($::ipa_clientinstall) {
    Package <| title == 'libsss_sudo' |> -> 
    File <| title == "sssd.conf-${host}" |> ~> 
    Exec["setupnisdomain-${host}"] ~>
    Service['sssd']
  }  

  if $ipa::master::sudo {
    exec { "set-sudopw-${host}":
      command   => "/bin/bash -c \"LDAPTLS_REQCERT=never /usr/bin/ldappasswd -x -H ldaps://${masterfqdn} -D uid=admin,cn=users,cn=accounts,${dc} -w ${adminpw} -s ${sudopw} uid=sudo,cn=sysaccounts,cn=etc,${dc}\"",
      unless    => "/bin/bash -c \"LDAPTLS_REQCERT=never /usr/bin/ldapsearch -x -H ldaps://${masterfqdn} -D uid=sudo,cn=sysaccounts,cn=etc,${dc} -w ${sudopw} -b cn=sysaccounts,cn=etc,${dc} uid=sudo\"",
      onlyif    => '/usr/sbin/ipactl status >/dev/null 2>&1',
      logoutput => 'on_failure'
    }
  }

}
