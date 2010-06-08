module GSLng
  backend.instance_eval do
    # trigonometric
    attach_function :gsl_sf_angle_restrict_symm, [ :double ], :double
    attach_function :gsl_sf_angle_restrict_pos, [ :double ], :double
  end
end
