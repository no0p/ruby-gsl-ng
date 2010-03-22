module GSLng
  # Random Number Generator class
  # @abstract You should use any of the descendant classes which implement the {#sample} method.
  class RNG
    # Create a Generator of the given type
    # @param [Symbol] generator_type the algorithm to use (without the +gsl_rng+ prefix). Default is :mt19937.
    # @see http://www.gnu.org/software/gsl/manual/html_node/Random-number-generator-algorithms.html
    def initialize(generator_type = nil)
      @type = generator_type
      if (@type.nil?) then @type = :mt19937 end # update comment above if changed
      
      type = GSLng.backend.send(:"gsl_rng_#{@type}")
      @ptr = GSLng.backend.gsl_rng_alloc(type)
      GSLng.set_finalizer(self, :gsl_rng_free, @ptr)
    end

    def initialize_copy
      ObjectSpace.undefine_finalizer(self)
      type = GSLng.backend.send(:"gsl_rng_#{@type}")
      @ptr = GSLng.backend.gsl_rng_alloc(type)
      GSLng.set_finalizer(self, :gsl_rng_free, @ptr)
    end
  end
end

require 'gslng/rng/gaussian'
require 'gslng/rng/uniform'