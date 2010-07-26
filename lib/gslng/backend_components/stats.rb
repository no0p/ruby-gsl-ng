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

    # absolute deviation
    attach_function :gsl_stats_absdev, [ :pointer, :size_t, :size_t ], :double
    attach_function :gsl_stats_absdev_m, [ :pointer, :size_t, :size_t, :double ], :double

    # skewness and kurtosis
    attach_function :gsl_stats_skew, [ :pointer, :size_t, :size_t ], :double
    attach_function :gsl_stats_skew_m_sd, [ :pointer, :size_t, :size_t, :double, :double ], :double
    attach_function :gsl_stats_kurtosis, [ :pointer, :size_t, :size_t ], :double
    attach_function :gsl_stats_kurtosis_m_sd, [ :pointer, :size_t, :size_t, :double, :double ], :double

    # autocorrelation
    attach_function :gsl_stats_lag1_autocorrelation, [ :pointer, :size_t, :size_t ], :double
    attach_function :gsl_stats_lag1_autocorrelation_m, [ :pointer, :size_t, :size_t, :double ], :double

    # covariance
    attach_function :gsl_stats_covariance, [ :pointer, :size_t, :pointer, :size_t, :size_t ], :double
    attach_function :gsl_stats_covariance_m, [ :pointer, :size_t, :pointer, :size_t, :size_t, :double, :double ], :double

    # correlation
    attach_function :gsl_stats_correlation, [ :pointer, :size_t, :pointer, :size_t, :size_t ], :double
  end
end
