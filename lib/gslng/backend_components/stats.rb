module GSLng
  backend.instance_eval do
    # mean, sd and variance
    attach_function :gsl_stats_mean, [ :pointer, :size_t, :size_t ], :double
    attach_function :gsl_stats_variance, [ :pointer, :size_t, :size_t ], :double
    attach_function :gsl_stats_variance_m, [ :pointer, :size_t, :size_t, :double ], :double
    attach_function :gsl_stats_sd, [ :pointer, :size_t, :size_t ], :double
    attach_function :gsl_stats_sd_m, [ :pointer, :size_t, :size_t, :double ], :double
    attach_function :gsl_stats_tss, [ :pointer, :size_t, :size_t ], :double
    attach_function :gsl_stats_tss_m, [ :pointer, :size_t, :size_t, :double ], :double
    attach_function :gsl_stats_variance_with_fixed_mean, [ :pointer, :size_t, :size_t, :double ], :double
    attach_function :gsl_stats_sd_with_fixed_mean, [ :pointer, :size_t, :size_t, :double ], :double   
  end
end
