module GSLng
  backend.instance_eval do

    # regression analysis
    attach_function :gsl_fit_linear, [:pointer, :double, :pointer, :double, :double, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer], :int

  end
end
