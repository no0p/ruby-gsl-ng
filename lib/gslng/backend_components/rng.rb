module GSLng
  backend.instance_eval do
    # memory handling
    attach_function :gsl_rng_alloc, [ :pointer ], :pointer
    attach_function :gsl_rng_free, [ :pointer ], :void

    # RNG types
    algorithms = %w(mt19937 ranlxs0 ranlxs1 ranlxs2 ranlxd1 ranlxd2 ranlux ranlux389 cmrg mrg taus taus2 gfsr4)
    algorithms.each do |alg|
      attach_variable :"gsl_rng_#{alg}", :pointer
    end

    # Uniform
    attach_function :gsl_ran_flat, [ :pointer, :double, :double ], :double
    attach_function :gsl_ran_flat_pdf, [ :double, :double, :double ], :double

    # Gaussian
    attach_function :gsl_ran_gaussian, [ :pointer, :double ], :double
    attach_function :gsl_ran_gaussian_ziggurat, [ :pointer, :double ], :double
    attach_function :gsl_ran_gaussian_ratio_method, [ :pointer, :double ], :double
  end
end