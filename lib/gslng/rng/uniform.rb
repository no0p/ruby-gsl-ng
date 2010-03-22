# To change this template, choose Tools | Templates
# and open the template in the editor.

module GSLng
  class RNG
    class Uniform < RNG
      # Creates a new Uniform distribution with values in [min,max)
      def initialize(min, max)
        super()
        @min,@max = min,max
      end
    end
  end
end
