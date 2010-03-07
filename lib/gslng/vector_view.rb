module GSLng
  class Vector
    # A View of a Vector.
    #
    # Views reference an existing Vector (or a row/column from a Matrix) and can be used to access parts of it without
    # having to copy it entirely. You can treat a View just like a Vector.
    # But note that modifying elements of a View will modify the elements of the original Vector/Matrix.
    #
    class View < Vector
      # The Vector owning the data this View uses
      # @return [Vector,Matrix]
      attr_reader :owner 

      def initialize(ptr, owner, offset, size) # @private
        @owner,@size,@ptr = owner,size,ptr
        GSLng.set_finalizer(self, :gsl_vector_free, @ptr)
      end
      
      # Returns a Vector (*NOT* a View) copied from this view. In other words,
      # you'll get a Vector which you can modify without modifying {#owner}'s elements
      # @return [Vector]
      def dup
        v = Vector.new(@size)
        GSLng.backend::gsl_vector_memcpy(v.ptr, @ptr)
        return v
      end
      alias_method :clone, :dup
      alias_method :to_vector, :dup

      def view # @private
        raise "Can't create a View from a View"
      end

      def inspect # @private
        "#{self}:VectorView"
      end
    end
  end
end
