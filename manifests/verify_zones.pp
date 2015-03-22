define bind::verify_zones (
  $allow_query    = undef,
  $also_notify    = undef,
  $file           = undef,
  $masters        = undef,
  $notifications  = undef,
  $path           = undef,
  $type           = undef,
) {

  if $allow_query != undef {
    validate_array($allow_query)
  }

  if $also_notify != undef {
    validate_array($also_notify)
  }

  if $file != undef {
    validate_string($file)
  }

  if $masters != undef {
    if $type != 'slave' {
      fail("Parameter 'masters' only valid when 'type' is 'slave' for bind::zones::${name}.")
    }

    validate_array($masters)
  }

  if $notifications != undef {
    validate_re($notifications, "^(yes|no)$")
  }

  if $path != undef {
    $path_real = $path
  } else {
    $path_real = $bind::zone_path
  }

  validate_absolute_path($path_real)
  include common
  common::mkdir_p{"${bind::fs_root_real}/${path_real}": }

  ensure_resource('file', "${bind::fs_root_real}/$path_real", { ensure => 'directory', owner => $bind::user, require => Common::Mkdir_p["${bind::fs_root_real}/$path_real"] } )

  if $type != undef {
    validate_re($type, "^(master|slave|hint)$")
  } else {
    fail("Missing mandatory parameter 'type' in bind::zones::${name}.")
  }
  if $type == 'slave' and $masters == undef {
    fail("Missing mandatory parameter 'masters' when 'type' is 'slave' for bind::zones::${name}.")
  }
}
