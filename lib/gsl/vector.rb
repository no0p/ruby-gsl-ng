module GSL
  # This class represents a fixed-size Vector object.
  #
  # Examples:
  # TODO!
  #
  # Notes:
  # * This class includes numerable, but certain methods are redefined (like #max and #min)
  # for fast versions that don't use #each. Calling #each (and therefore, any other Enumerable's method) is slower.
  #
  # TODO: add type coercions
  class Vector
    include Enumerable
    
    attr_reader :ptr #:nodoc:
    
    # Create a Vector of size n. If zero is true, the vector is initialized with zeros
    # Otherwise, the vector will contain garbage.
    def initialize(n, zero = false)
      if (zero) then @ptr = GSL::Backend::gsl_vector_calloc(n)
      else @ptr = GSL::Backend::gsl_vector_alloc(n) end
      GSL.set_finalizer(self, :gsl_vector_free, @ptr)
      
      @size = n # TODO: extract from @ptr
    end
    
    def initialize_copy(other)
      @ptr = GSL::Backend::gsl_vector_alloc(other.size)
      GSL.set_finalizer(self, :gsl_vector_free, @ptr)
      
      @size = other.size
      GSL::Backend::gsl_vector_memcpy(@ptr, other.ptr)
    end
    
    # copies other's values into self
    def copy(other)
      GSL::Backend::gsl_vector_memcpy(@ptr, other.ptr)
    end
    
    # sets all values to v
    def all!(v); GSL::Backend::gsl_vector_set_all(v) end
    
    # zeroes all values
    def zero!; GSL::Backend::gsl_vector_set_zero(v) end
    
    # sets all zeros, and a 1 on the i-th position
    def basis!(i); GSL::Backend::gsl_vector_set_basis(i) end
    
    # Add other to self
    def add(other)
      case other.class
      when Numeric; GSL::Backend::gsl_vector_add_constant(@ptr, other.to_f)
      when Vector; GSL::Backend::gsl_vector_add(@ptr, other.ptr)
      else raise TypeError, 'Unsupported type' end
    end
    
    # Substract other from self
    def sub(other)
      case other.class
      when Numeric; GSL::Backend::gsl_vector_add_constant(@ptr, -other.to_f)
      when Vector; GSL::Backend::gsl_vector_sub(@ptr, other.ptr)
      else raise TypeError, 'Unsupported type' end
    end
    
    # Multiply (element-by-element) other with self
    def mul(other)
      case other.class
      when Numeric; GSL::Backend::gsl_blas_dscal(other.to_f, @ptr)
      when Vector; GSL::Backend::gsl_vector_mul(@ptr, other.ptr)
      else raise TypeError, 'Unsupported type' end
    end
    
    # Divide (element-by-element) self by other
    def div(other)
      case other.class
      when Numeric; GSL::Backend::gsl_vector_scale(1.0 / other, @ptr)
      when Vector;  GSL::Backend::gsl_vector_div(@ptr, other.ptr)
      else raise TypeError, 'Unsupported type' end
    end
    
    def +(other); self.dup.add(other) end
    def -(other); self.dup.sub(other) end
    def *(other); self.dup.mul(other) end
    def /(other); self.dup.div(other) end
    
    # Reverse the order of elements
    def reverse!; GSL::Backend::gsl_vector_reverse(@ptr) end
    
    # Swap the i-th element with the j-th element
    def swap(i,j); GSL::Backend::gsl_vector_swap_elements(@ptr, i, j) end
    
    def [](i); GSL::Backend::gsl_vector_get(@ptr, i) end
    def []=(i, v); GSL::Backend::gsl_vector_set(@ptr, i, v.to_f) end
    
    # if all elements are zero
    def zero?; GSL::Backend::gsl_vector_isnull(@ptr) == 1 ? true : false end
    # if all elements are strictly positive (>0)
    def positive?; GSL::Backend::gsl_vector_ispos(@ptr) == 1 ? true : false end
    #if all elements are strictly negative (<0)
    def negative?; GSL::Backend::gsl_vector_isneg(@ptr) == 1 ? true : false end
    # if all elements are non-negative (>=0)
    def nonnegative?; GSL::Backend::gsl_vector_isnonneg(@ptr) == 1 ? true : false end
    
    def max; GSL::Backend::gsl_vector_max(@ptr) end
    def min; GSL::Backend::gsl_vector_min(@ptr) end
    
    def minmax
      min = FFI::MemoryPointer.new(:double)
      max = FFI::MemoryPointer.new(:double)
      GSL::Backend::gsl_vector_minmax(@ptr, min, max)      
      return [min[0].get_float64(0),max[0].get_float64(0)]
    end
    
    def minmax_index
      min = FFI::MemoryPointer.new(:uint)
      max = FFI::MemoryPointer.new(:uint)
      GSL::Backend::gsl_vector_minmax_index(@ptr, min, max)      
      return [min[0].get_uint(0),max[0].get_uint(0)]
    end
    
    # Same as #min, but returns the index to the element
    def min_index; GSL::Backend::gsl_vector_min(@ptr) end
    # Same as #max, but returns the index to the element    
    def max_index; GSL::Backend::gsl_vector_min(@ptr) end
    
    # Dot product between self and other
    def dot(other)
      out = FFI::MemoryPointer.new(:double)
      GSL::Backend::gsl_blas_ddot(@ptr, other.ptr, out)
      return out[0].get_float64(0)
    end
    alias_method :^, :dot
    
    # Norm 2 of the vector
    def norm; GSL::Backend::gsl_blas_dnrm2(@ptr) end
    alias_method :length, :norm

    # Returns the sum of all elements
    def sum; GSL::Backend::gsl_blas_dasum(@ptr) end

    # Optimized version of: self = self * alpha + other (where alpha is a Numeric)
    def mul_add(other, alpha); GSL::Backend::gsl_blas_daxpy(alpha, @ptr, other.ptr) end
    
    # Yields the block for each element in the Vector
    def each
      # TODO: replace with a C function that uses a callback to call the given block, may be faster
      @size.times do |i| yield(self[i]) end
    end
  end
end
