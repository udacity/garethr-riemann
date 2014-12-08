class riemann::install {
  include wget
  include java

  case $::osfamily {
    'Debian': {
      exec { 'riemann-apt-get-update':
        command     => '/usr/bin/apt-get update',
        before      => Class['java'],
      }
    }
    'RedHat', 'Amazon': {
      ensure_resource('package', 'daemonize', {'ensure' => 'present' })
    }
    default: {}
  }

  file { '/opt/riemann':
    ensure  => link,
    target  => "/opt/riemann-${riemann::version}",
    owner   => $riemann::user,
    require => User[$riemann::user],
  }

  user { $riemann::user:
    ensure => present,
  }

  file { "/opt/riemann-${riemann::version}":
    ensure  => directory,
    owner   => $riemann::user,
    require => User[$riemann::user],
  }

  riemann::download { 'download_riemann':
    provider => git,
    source => 'https://github.com/udacity/garethr-riemann.git',
    revision => '1ba59a5ea21d24702c8bbad07013486fe31903cc',
    user => $riemann::user,
    before => File['/opt/riemann'],
    require => File["/opt/riemann-${riemann::version}"],
  }

}
