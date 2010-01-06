module GSLng
  class Matrix
    # A View of a Matrix.
    #
    # Views reference an existing Matrix and can be used to access parts of it without having to copy
    # it entirely. You can treat a View just like a Matrix.
    # But note that modifying elements of a View will modify the elements of the original matrix.
    #
    class View < Matrix
      attr_reader :owner # The Matrix owning the data this View uses

      # Create a MatrixView of the sub-matrix starting at (x,y), of size (m,n)
      def initialize(owner, x, y, m, n) #:nodoc:
        @owner = owner
        @m,@n = m,n
        @ptr = GSLng.backend::gsl_matrix_submatrix2(owner.ptr, x, y, m, n)
        GSLng.set_finalizer(self, :gsl_matrix_free, @ptr)
      end

      # Returns a Matrix (*NOT* a View) copied from this view. In other words,
      # you'll get a Matrix which you can modify without modifying #owner elements.
      def dup
        matrix = Matrix.new(@m, @n)
        GSLng.backend::gsl_matrix_memcpy(matrix.ptr, @ptr)
        return matrix
      end
      alias_method :clone, :dup
      alias_method :to_matrix, :dup

      def view  #:nodoc:
        raise "Can't create a View from a View"
      end

      def inspect #:nodoc:
        "#{self}:MatrixView"
      end
    end
  end
end
