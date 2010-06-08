module GSLng
  # A group of several different special functions.
  #
  # =Notes
  # You can use this module simply by acessing its functions. Optionally, you can also extend the +Math+ standard module
  # with these methods by doing:
  #  Math.extend(GSLng::Special)
  #
  module Special
    extend self # allow this module to be used as such, and as a mixin

    # Restrict the given angle to the interval (-pi,pi]
    def angle_restrict_symm(theta)
      GSLng.backend.gsl_sf_angle_restrict_symm(theta)
    end

    # Restrict the given angle to the interval (0,2pi]
    def angle_restrict_pos(theta)
      GSLng.backend.gsl_sf_angle_restrict_pos(theta)
    end
  end
end