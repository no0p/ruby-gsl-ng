#!/usr/bin/ruby
require 'mkmf'
gsl_vars = pkg_config('gsl') or raise 'GSL not found!'
extra_flags='-O3'
with_cppflags("#{$CPPFLAGS} #{extra_flags}") { true }
create_makefile('gslng_extensions')
