require 'ffi'

module GSLng
  # This module encapsulates the communication with the plotting backend: PLplot.
  module Plotter
    @backend = Module.new do
      extend FFI::Library
      ffi_lib 'plplotd', FFI::CURRENT_PROCESS

      # init/deinit
      attach_function :plstart, :c_plstart, [ :string, :long, :long ], :void
      attach_function :plinit, :c_plinit, [], :void
      attach_function :plend, :c_plend, [], :void
      attach_function :plsdev, :c_plsdev, [ :string ], :void
      attach_function :plenv, :c_plenv, [ :double, :double, :double, :double, :long, :long ], :void

      # plots
      attach_function :plimage, :c_plimage, [ :pointer, :long, :long, :double, :double, :double,
                                              :double, :double, :double, :double, :double, :double, :double ], :void
      attach_function :plimagefr, :c_plimagefr, [ :pointer, :long, :long, :double, :double, :double,
                                              :double, :double, :double, :double, :double, :pointer, :pointer ], :void

      # colors
      attach_function :plscolbg, :c_plscolbg, [ :long, :long, :long ], :void


      # misc
      attach_function :plflush, :c_plflush, [], :void
      attach_function :plspause, :c_plspause, [ :bool ], :void

      # internal
      attach_function :plplot_alloc_plplotgrid, [ :pointer ], :pointer
      attach_function :plplot_free_plplotgrid, [ :pointer, :size_t ], :void
      attach_function :plplot_set_grayscale, [], :void
      
      # error handling
      callback :error_handler_callback, [ :string, ], :int
      callback :abort_handler_callback, [ :string, ], :void
      attach_function :plsexit, [ :error_handler_callback ], :void
      attach_function :plsabort, [ :abort_handler_callback ], :void

      ErrorHandlerCallback = Proc.new {|msg| raise RuntimeError, "PLplot error: #{msg}", caller[2..-1]}
      AbortHandlerCallback = Proc.new {|msg| raise RuntimeError, "PLplot aborted: #{msg}", caller[2..-1]}
      self.plsexit(ErrorHandlerCallback)
      self.plsabort(AbortHandlerCallback)
    end

    # Returns the internal backend module
    def self.backend # @private
      @backend
    end
  end
end
