require 'ffi'

module GSLng
  # This module encapsulates the communication with the plotting backend: PLplot.
  module Plotter
    @backend = Module.new do
      extend FFI::Library
      ffi_lib 'plplotd', 'csirocsa', 'csironn', 'qhull', 'qsastime'
      
      attach_function :plinit, :c_plinit, [], :void
      attach_function :plend, :c_plend, [], :void
      attach_function :plsdev, :c_plsdev, [ :string ], :void
    end

    # Returns the internal backend module
    def self.backend # @private
      @backend
    end
  end
end
