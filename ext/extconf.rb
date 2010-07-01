#!/usr/bin/ruby
require 'mkmf'

extra_flags='-O4 -DHAVE_INLINE=1'

## Check for GSL
gsl_vars = pkg_config('gsl') or raise 'GSL not found!'

## Check for PLplot
plplot_vars = pkg_config('plplotd')

if (plplot_vars.nil?)
  message("PLplot was NOT found. Disabling PLplot support (NOTE: double-precision version is only supported)")
else
  puts "Enabling PLplot support"
  extra_flags += ' -DHAVE_PLPLOT'
end

## Create Makefile
with_cppflags("#{extra_flags}") { true }
create_makefile('gslng_extensions')
