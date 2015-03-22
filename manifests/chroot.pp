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
}
