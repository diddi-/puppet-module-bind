class bind::options (
  $directory          = '/var/cache/bind',
  $dnssec_validation  = 'auto',
  $auth_nxdomain      = 'no',
  $listen_on_v6       = ['any'],
  $allow_transfer     = ['none'],
  $allow_query        = ['none'],
  $allow_recursion    = ['none'],
  $allow_recursion_on = ['none'],
  $allow_query_cache  = ['none'],
  $version            = 'none',
  $forwarders         = ['none'],
  $root_hint          = 'true',

) {

  validate_absolute_path($directory)
  validate_re($dnssec_validation, "^(yes|no|auto)$")
  validate_re($auth_nxdomain, "^(yes|no)$")
  validate_array($listen_on_v6)
  validate_array($allow_transfer)
  validate_array($allow_recursion)
  validate_array($allow_recursion_on)
  validate_array($allow_query_cache)
  validate_string($version) 
  validate_array($forwarders)

  if is_string($root_hint) == true {
    $root_hint_real = str2bool($root_hint)
  } else {
    $root_hint_real = $root_hint
  }  
  validate_bool($root_hint_real)

}
