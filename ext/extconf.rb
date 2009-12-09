#!/usr/bin/ruby
require 'mkmf'
gsl_vars = pkg_config('gsl') or raise 'GSL not found!'
create_makefile('gslng_extensions')
