define bind::verify_zones (
  $allow_query    = undef,
  $also_notify    = undef,
  $file           = undef,
  $masters        = undef,
  $notifications  = undef,
  $type           = undef,
) {

  if $allow_query != undef {
    validate_array($allow_query)
  }

  if $also_notify != undef {
    validate_array($also_notify)
  }

  if $file != undef {
    validate_absolute_path($file)
  } else {
    fail("Missing mandatory parameter 'file' in bind::zones::${name}.")
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

  if $type != undef {
    validate_re($type, "^(master|slave|hint)$")
  } else {
    fail("Missing mandatory parameter 'type' in bind::zones::${name}.")
  }
  if $type == 'slave' and $masters == undef {
    fail("Missing mandatory parameter 'masters' when 'type' is 'slave' for bind::zones::${name}.")
  }
}
