module GSLng
  class RNG
    class Uniform < RNG
      attr_reader :ptr # @private
      
      # Creates a new Uniform distribution with values in [min,max)
      # @param [Float] min
      # @param [Float] max
      # @param generator_type (see GSLng::RNG#initialize)
      def initialize(min, max, generator_type = nil)
        super(generator_type)
        @min,@max = min,max
      end

      # Obtain a sample from this distribution
      # @return [Float]
      def sample
        GSLng.backend.gsl_ran_flat(self.ptr, @min, @max)
      end
      alias_method :get, :sample
    end
  end
end
