class bind::chroot (
  $path  = $bind::chroot_path,
) {

  include common
  include types

  validate_absolute_path($path)
  common::mkdir_p{"${path}": }

  file { "$path": 
    ensure => 'directory',
    require => Common::Mkdir_p["${path}"],
  }

  file { "${path}/dev": 
    ensure  => 'directory',
    owner   => $bind::user,
    require => File["$path"],
  }

  types::mknod{"${path}/dev/random":
    type    => 'c',
    major   => '1',
    minor   => '8',
    require => File["${path}/dev"],
  }

  types::mknod{"${path}/dev/null":
    type    => 'c',
    major   => '1',
    minor   => '3',
    require => File["${path}/dev"],
  }

  if is_string($bind::symlink_etc) == true {
    $symlink_etc_real = str2bool($bind::symlink_etc)
  } else {
    $symlink_etc_real = $bind::symlink_etc
  }

  if $symlink_etc_real == true {
    file{ "/etc/bind":
      ensure => "link",
      target => "${path}/etc/bind/",
      force  => true,
    }
  }

  # Workaround to fix the named.pid path
  # as debian init-script insist on hardcoding the path...
  exec { "stop-bind-once":
    command => "/etc/init.d/${bind::bind_name_real} stop",
    require => Package[$bind::bind_package_real],
  }

  file { "${bind::pidfile_real}":
    ensure => 'link',
    target => "${path}/$bind::pidfile_real",
    force  => true,
    require => [Exec['stop-bind-once'], Package[$bind::bind_package_real]],
  }
}
