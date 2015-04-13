# Module: monit
#
# A puppet module to configure the monit service, and add definitions to be
# used from other classes and modules.
#
# Stig Sandbeck Mathisen <ssm@fnord.no>
# Micah Anderson micah@riseup.net
#
# To set any of the following, simply set them as variables in your manifests
# before the class is included, for example:
#
# $monit_enable_httpd = yes
# $monit_httpd_port = 8888
# $monit_secret="something secret, something safe"
# $monit_alert="someone@example.org"
# $monit_mailserver="mail.example.org"
# $monit_pool_interval="120"
#
# include monit
#
# The following is a list of the currently available variables:
#
# monit_alert:                who should get the email notifications?
#                             Default: root@localhost
#
# monit_enable_httpd:         should the httpd daemon be enabled?
#                             set this to 'yes' to enable it, be sure
#                             you have set the $monit_default_secret
#                             Valid values: yes or no
#                             Default: no
#
# monit_httpd_port:           what port should the httpd run on?
#                             Default: 2812
#
# monit_mailserver:           where should monit be sending mail?
#                             set this to the mailserver
#                             Default: localhost
#
# monit_pool_interval:        how often (in seconds) should monit poll?
#                             Default: 120
#
# monit_log_location:         where should monit write logs to?
#                             Default: syslog
#
class monit(
  $monit_enable_httpd  = 'no',
  $monit_httpd_port    = 2812,
  $monit_password      = 'This is not very secret, is it?',
  $monit_user          = 'monit',
  $monit_alert         = 'root@localhost',
  $monit_mailserver    = 'localhost',
  $monit_pool_interval = '120',
  $monit_log_location  = 'syslog facility log_daemon'
) {
  $fqdn = $::fqdn

  # The package
  package { 'monit':
    ensure => installed,
  }

  # The service
  service { 'monit':
    ensure  => running,
    require => Package['monit'],
  }

  # How to tell monit to reload its configuration
  exec { 'monit reload':
    command     => 'monit reload',
    path        => ['/usr/bin', '/usr/sbin'],
    refreshonly => true,
  }

  # Default values for all file resources
  File {
    owner   => 'root',
    group   => 'root',
    mode    => 0400,
    notify  => Exec['monit reload'],
    require => Package['monit'],
  }

  # The main configuration directory, this should have been provided by
  # the "monit" package, but we include it just to be sure.
  file { '/etc/monit':
    ensure => directory,
    mode   => '0700',
  }

  # The configuration snippet directory.  Other packages can put
  # *.monitrc files into this directory, and monit will include them.
  file { '/etc/monit/conf.d':
    ensure => directory,
    mode   => '0700',
  }

  # The main configuration file
  $mailname = $::mailname
  file { '/etc/monit/monitrc':
    ensure  => present,
    content => template('monit/monitrc.erb'),
  }

  # Monit is disabled by default on debian / ubuntu
  case $::osfamily {
    'Debian': {
      case $::lsbdistcodename {
        'squeeze', 'lucid': {
          $default_boot      = 'startup=1'
          $default_options   = "CHECK_INTERVALS=${monit_pool_interval}"
        # untested and therefore disabled
        #   $service_hasstatus = false
        }
        'precise': {
          $default_boot      = 'START=yes'
          $default_options   = "MONIT_OPTS=\"-d ${monit_pool_interval}\""
        # untested and therefore disabled
        #   $service_hasstatus = true
        }
        default: {
          $default_boot      = 'START=yes'
          $default_options   = "MONIT_OPTS=\"\""
        # untested and therefore disabled
        #   $service_hasstatus = true
        }
      }
      file { '/etc/default/monit':
        ensure  => present,
        content => "# managed by puppet\n${default_boot}\n${default_options}",
        before  => Service['monit'],
      }
    }
    default : {
    }
  }

  # A template configuration snippet.  It would need to be included,
  # since monit's "include" statement cannot handle an empty directory.
  monit::snippet{ 'monit_template':
    source => "puppet://${::server}/modules/monit/template.monitrc",
  }
}
