#!/usr/bin/ruby
require 'mkmf'

extra_flags='-O4 -DHAVE_INLINE=1'

## Check for GSL
find_executable('pkg-config') or raise 'pkg-config should be installed'
gsl_vars = pkg_config('gsl') or raise 'GSL not found!'

# Configuration
if (RUBY_VERSION =~ /^1\.8/) then $libs << ' -lstdc++' end # Seems necessary in some cases

## Create Makefile
with_cppflags("#{extra_flags}") { true }
create_makefile('gslng_extensions')
