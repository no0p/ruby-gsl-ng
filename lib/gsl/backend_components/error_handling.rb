module GSL
	backend.instance_eval do
		callback :error_handler_callback, [ :string, :string, :int, :int ], :void
    attach_function :gsl_set_error_handler, [ :error_handler_callback ], :error_handler_callback

    ErrorHandlerCallback = Proc.new {|reason, file, line, errno|
      raise RuntimeError, "#{reason} (errno: #{errno})", caller[2..-1]
    }
    gsl_set_error_handler(ErrorHandlerCallback)
	end
end