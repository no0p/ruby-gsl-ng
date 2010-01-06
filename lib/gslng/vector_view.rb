module GSLng
  class Vector
    # A View of a Vector.
    #
    # Views reference an existing Vector and can be used to access parts of it without having to copy
    # it entirely. You can treat a View just like a Vector.
    # But note that modifying elements of a View will modify the elements of the original vector.
    #
    class View < Vector
      attr_reader :owner # The Vector owning the data this View uses
      
      def initialize(owner, offset, size, stride = 1) #:nodoc:
        @owner = owner
        @size = size
        if (stride == 1) then @ptr = GSLng.backend::gsl_vector_subvector2(owner.ptr, offset, size)
        else @ptr = GSLng.backend::gsl_vector_subvector_with_stride2(owner.ptr, offset, stride, size) end
        GSLng.set_finalizer(self, :gsl_vector_free, @ptr)
      end

      # Returns a Vector (*NOT* a View) copied from this view. In other words,
      # you'll get a Vector which you can modify without modifying #owner elements
      def dup
        v = Vector.new(@size)
        GSLng.backend::gsl_vector_memcpy(v.ptr, @ptr)
        return v
      end
      alias_method :clone, :dup
      alias_method :to_vector, :dup

      def view #:nodoc:
        raise "Can't create a View from a View"
      end

      def inspect #:nodoc:
        "#{self}:VectorView"
      end
    end
  end
end
