require 'ffi'

module GSL
	# Anonymous module: avoids exposing this internal module when doing "include GSL" at the top-level.
	# If ruby had "private" modules I wouldn't have to do this.
  @backend = Module.new do
    extend FFI::Library
  end

	# Returns the internal backend module
	def GSL.backend; @backend end
end

require 'gsl/backend_components/vector'
require 'gsl/backend_components/error_handling'
