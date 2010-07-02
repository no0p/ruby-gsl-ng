#!/usr/bin/ruby
require 'mkmf'

extra_flags='-O4 -DHAVE_INLINE=1'

## Check for GSL
gsl_vars = pkg_config('gsl') or raise 'GSL not found!'

## Create Makefile
with_cppflags("#{extra_flags}") { true }
create_makefile('gslng_extensions')
