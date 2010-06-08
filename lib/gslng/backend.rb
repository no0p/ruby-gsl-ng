require 'ffi'

module GSLng
  # Anonymous module: avoids exposing this internal module when doing "include GSLng" at the top-level.
  # If ruby had "private" modules I wouldn't have to do this.
  @backend = Module.new do
    extend FFI::Library
    ffi_lib(FFI::CURRENT_PROCESS)

    SUPPORTED_TYPES=[ :double ]

    # This function lets me attach "templatized" functions from C, for the different data types
    # GSL allows for vectors/matrices/etc.
    def self.attach_polymorphic(function, input, output)
      SUPPORTED_TYPES.each do |t|
        new_function = function.to_s.sub(/T_/, (t == :double ? '' : "#{t}_")).to_sym
        new_input = input.map {|i| i == :* ? t : i}
        new_output = (output == :* ? t : output)
        attach_function new_function, new_input, new_output
      end
    end
  end

  # Returns the internal backend module
  def GSLng.backend # @private
    @backend
  end
end

require 'gslng_extensions'
require 'gslng/backend_components/vector'
require 'gslng/backend_components/matrix'
require 'gslng/backend_components/error_handling'
require 'gslng/backend_components/rng'
require 'gslng/backend_components/special'
