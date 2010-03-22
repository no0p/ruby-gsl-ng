module GSLng
  # Random Number Generator class. Tipically you'd instantiate one of its child classes
  # to get a concrete Random distribution (like RNG::Uniform, RNG::Gaussian, etc).
  class RNG
    # Create a Generator of the given type
    # @param [Symbol] type the algorithm to use (without the +gsl_rng+ prefix)
    # @see http://www.gnu.org/software/gsl/manual/html_node/Random-number-generator-algorithms.html
    def initialize(type = :mt19937)
      @ptr = GSLng.backend.gsl_rng_alloc(type)
      GSLng.set_finalizer(self, :gsl_rng_free, @ptr)
    end

    def initialize_copy
      ObjectSpace.undefine_finalizer(self)
      @ptr = GSLng.backend.gsl_rng_alloc(type)
      GSLng.set_finalizer(self, :gsl_rng_free, @ptr)
    end
  end
end
