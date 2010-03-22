module GSLng
  class RNG
    class Gaussian < RNG
      attr_reader :ptr # @private

      attr_reader :mu, :sigma
      
      # Creates a new Gaussian distribution
      # @param [Float] mu mean
      # @param [Float] sigma standard deviation
      # @param [Symbol] sample_method The method to use to sample numbers. Can be either :boxmuller, :ziggurat or :ratio_method
      # @param generator_type (see GSLng::RNG#initialize)
      # @see http://www.gnu.org/software/gsl/manual/html_node/The-Gaussian-Distribution.html
      def initialize(mu = 0, sigma = 1, sample_method = :boxmuller, generator_type = nil)
        super(generator_type)
        @mu,@sigma = mu,sigma

        case sample_method
        when :boxmuller; @function = :gsl_ran_gaussian
        when :ziggurat; @function = :gsl_ran_gaussian_ziggurat
        when :ratio_method; @function = :gsl_ran_ratio_method
        else raise "Unsupported method"
        end
      end

      # Obtain a sample from this distribution
      # @return [Float]
      def sample
        GSLng.backend.send(@function, self.ptr, @sigma) + @mu
      end
      alias_method :get, :sample
    end
  end
end
