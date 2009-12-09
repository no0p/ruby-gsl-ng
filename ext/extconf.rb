#!/usr/bin/ruby
require 'mkmf'
gsl_vars = pkg_config('gsl')
create_makefile('gslng_extensions')
