class bind (
  $acl                  = undef,
  $bind_name            = 'USE_DEFAULTS',
  $bind_package         = 'USE_DEFAULTS',
  $chroot_path          = undef,
  $default_file_path    = 'USE_DEFAULTS',
  $ensure               = 'running',
  $fs_root              = '/',
  $masters              = undef,
  $manage_default_file  = 'USE_DEFAULTS',
  $pidfile              = 'USE_DEFAULTS',
  $rndc_binary          = 'USE_DEFAULTS',
  $rundir               = 'USE_DEFAULTS',
  $symlink_etc          = true,
  $user                 = 'bind',
  $zone_path            = '/etc/bind/zones',
  $zones                = undef,
) {

  include bind::options

  case $::operatingsystem {
    'Debian': {
      $default_bind_name = "bind9"
      $default_manage_default_file  = true
      $default_default_file_path = '/etc/default/bind9'
      $default_bind_package = 'bind9'
      $default_pidfile = '/var/run/named/named.pid'
      $default_rundir = '/var/run/named'
      $default_rndc_binary = '/usr/sbin/rndc-confgen'
    }
    default: {
      fail("bind module is not supported on $::operatingsystem.")
    }
  }

  validate_re($ensure, "^(running|true|stopped|false)$")
  validate_string($user)

  if $pidfile == 'USE_DEFAULTS' {
    $pidfile_real = $default_pidfile
  } else {
    $pidfile_real = $pidfile
  }
  validate_absolute_path($pidfile_real)

  if $chroot_path != undef {
    include bind::chroot
    $fs_root_real = $chroot_path
  } else {
    $fs_root_real = $fs_root
  }

  if $acl != undef {
    validate_hash($acl)
  }

  if $bind_name == 'USE_DEFAULTS' {
    $bind_name_real = $default_bind_name
  } else {
    $bind_name_real = $bind_name
  }
  validate_string($bind_name_real)

  if $bind_package == 'USE_DEFAULTS' {
    $bind_package_real = $default_bind_package
  } else {
    $bind_package_real = $bind_package
  }
  validate_string($bind_package_real)

  if $manage_default_file == 'USE_DEFAULTS' {
    $manage_default_file_real = $default_manage_default_file
  } else {
    $manage_default_file_real = $manage_default_file
  }
  validate_bool($manage_default_file_real)

  if $default_file_path == 'USE_DEFAULTS' {
    $default_file_path_real = $default_default_file_path
  } else {
    $default_file_path_real = $default_file_path
  }

  if $masters != undef {
    validate_hash($masters)
  }

  if $rndc_binary == 'USE_DEFAULTS' {
    $rndc_binary_real = $default_rndc_binary
  } else {
    $rndc_binary_real = $rndc_binary
  }

  if $rundir == 'USE_DEFAULTS' {
    $rundir_real = $default_rundir
  } else {
    $rundir_real = $rundir
  }
  validate_absolute_path($rundir_real)

  validate_absolute_path($zone_path)

  if $zones != undef {
    validate_hash($zones)
    create_resources('bind::verify_zones', $zones)
  }


  package { "$bind_package_real": 
    ensure => present,
  }
  
  if $manage_default_file_real == true {
    file { "$default_file_path_real": 
      ensure  => file,
      content => template("bind/${::operatingsystem}_default.erb"),
      require => Package[$bind_package_real],
      notify  => Service['bind'],
    }
  }

  include common

  common::mkdir_p{"${fs_root_real}/${bind::options::directory}": }
  file { "${fs_root_real}/${bind::options::directory}":
    ensure => 'directory',
    owner  => $bind::user,
    require => [Class['bind::options'], Common::Mkdir_p["${fs_root_real}/${bind::options::directory}"]],
  }

  common::mkdir_p{"${fs_root_real}/etc/bind": }
  file { "${fs_root_real}/etc/bind":
    ensure  => 'directory',
    owner   => $bind::user,
    require => [Common::Mkdir_p["${fs_root_real}/etc/bind"]],
  }
  file { "${fs_root_real}/etc/bind/db.root":
    ensure  => 'file',
    owner   => $bind::user,
    content => template("bind/db.root.erb"),
    require => [File["${fs_root_real}/etc/bind"]],
  }
  exec { "${fs_root_real}/etc/bind/rndc.key":
    command => "${rndc_binary_real} -t ${fs_root_real} -a",
    creates => "${fs_root_real}/etc/bind/rndc.key",
    user    => $bind::user,
  }

  common::mkdir_p{"${fs_root_real}/${rundir_real}": }
  file { "${fs_root_real}/${rundir_real}":
    ensure  => 'directory',
    owner   => $bind::user,
    require => [Common::Mkdir_p["${fs_root_real}/${rundir_real}"]],
  }

  if $chroot_path == undef {
    file { "$fs_root_real/etc/bind/named.conf": 
      ensure   => file,
      owner    => $bind::user,
      content  => template("bind/named.conf.erb"),
      notify   => Service['bind'],
      require  => [Class['bind::options']],
    }

    service { 'bind':
      name   => $bind_name_real,
      ensure => $ensure,
      enable => true,
      hasrestart => true,
      require => Package[$bind_package_real],
    }
  } else {
    file { "$fs_root_real/etc/bind/named.conf": 
      ensure   => file,
      owner    => $bind::user,
      content  => template("bind/named.conf.erb"),
      notify   => Service['bind'],
      require  => [Class['bind::chroot'], Class['bind::options']],
    }

    service { 'bind':
      name   => $bind_name_real,
      ensure => $ensure,
      enable => true,
      hasrestart => true,
      require => [Package[$bind_package_real], Class['bind::chroot']],
    }
  }
}
