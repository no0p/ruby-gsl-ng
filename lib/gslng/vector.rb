module GSLng
  # A fixed-size n-dimensional vector.
  #
  # =Examples
	#  Vector[1,2,3] + Vector[2,3,4] => Vector[3,5,7]
	#  Vector[1,2,3] + 0.5 => Vector[1.5,2.5,3.5]
	# Same goes for *, /, and - operators. The are also self-modifying versions (#add, #mul, #div, #sub).
	#
  # Note also that operator ^ produces the #dot product:
	#  Vector[1,2,3] ^ Vector[2,3,4] => 20
	#
  # =Notes
  # * This class includes Enumerable, but certain methods are redefined (like #max and #min)
  #   for fast versions that don't use #each. Calling #each (and therefore, any other Enumerable's method) is slower.
	# * #each is implemented through calls to #[], which can be relatively slow (compared to direct C pointer access)
	#   for big Vectors. It would be possible to have a faster version that iterates on the C-side and calls a block for each
	#   element, but in that case it wouldn't be possible to expect a return value of any type. This complicates things for methods like
	#   #any? which expect a boolean value.
	# * Some functions (like #sum, #dot, and others) use BLAS functions (through GSLng's CBLAS interface).
	# * In contrary to Array, operators [] and []= will raise an exception when accessing out-of-bounds elements.
  #
  class Vector
    include Enumerable
    
    attr_reader :ptr	# :nodoc:
    attr_reader :size # Vector size
    
    # Create a Vector of size n. If zero is true, the vector is initialized with zeros.
    # Otherwise, the vector will contain garbage.
		# You can optionally pass a block, in which case #map_index! will be called with it (i.e.: it works like Array.new).
    def initialize(n, zero = false)
      @ptr = (zero ? GSLng.backend::gsl_vector_calloc(n) : GSLng.backend::gsl_vector_alloc(n))
      GSLng.set_finalizer(self, :gsl_vector_free, @ptr)
      
      @size = n # TODO: extract from @ptr

			if (block_given?) then self.map_index!(&Proc.new) end
    end

    def initialize_copy(other) #:nodoc:
      ObjectSpace.undefine_finalizer(self) # TODO: ruby bug?
      @ptr = GSLng.backend::gsl_vector_alloc(other.size)
      GSLng.set_finalizer(self, :gsl_vector_free, @ptr)
      
      @size = other.size
      GSLng.backend::gsl_vector_memcpy(@ptr, other.ptr)
    end

		# Same as Vector.new(n, true)
		def Vector.zero(n); Vector.new(n, true) end

		# Create a vector from an Array
		def Vector.from_array(array)
			if (array.empty?) then raise "Can't create empty vector" end
			Vector.new(array.size) {|i| array[i]}
		end

		# Creates a Vector from an Array (see #from_array) or a Range
		def Vector.[](*args)
      array = (args.size == 1 && Range === args[0] ? args[0].to_a : args)
			Vector.from_array(array)
		end

    # Generates a Vector of n random numbers between 0 and 1.
    # NOTE: This simply uses Kernel::rand
    def Vector.random(n)
			Vector.new(n).map!{|x| Kernel::rand}
    end
		class << self; alias_method :rand, :random end
    
    # Copy other's values into self
    def copy(other); GSLng.backend::gsl_vector_memcpy(self.ptr, other.ptr); return self end
    
    # Set all values to v
    def all!(v); GSLng.backend::gsl_vector_set_all(self.ptr, v); return self end
		alias_method :set!, :all!
		alias_method :fill!, :all!
    
    # Set all values to zero
    def zero!; GSLng.backend::gsl_vector_set_zero(self.ptr); return self end
    
    # Set all values to zero, except the i-th element, which is set to 1
    def basis!(i); GSLng.backend::gsl_vector_set_basis(self.ptr, i); return self end
    
    # Add other to self
    def add(other)
      case other
      when Numeric; GSLng.backend::gsl_vector_add_constant(self.ptr, other.to_f)
      when Vector; GSLng.backend::gsl_vector_add(self.ptr, other.ptr)
      else
				puts "aca"
				x,y = other.coerce(self)
				x.add(y)
			end
			return self
    end
    
    # Substract other from self
    def sub(other)
      case other
      when Numeric; GSLng.backend::gsl_vector_add_constant(self.ptr, -other.to_f)
      when Vector; GSLng.backend::gsl_vector_sub(self.ptr, other.ptr)
      else
				x,y = other.coerce(self)
				x.sub(y)
			end
			return self
    end
    
    # Multiply (element-by-element) other with self
    def mul(other)
      case other
      when Numeric; GSLng.backend::gsl_blas_dscal(other.to_f, self.ptr)
      when Vector; GSLng.backend::gsl_vector_mul(self.ptr, other.ptr)
      else
				x,y = other.coerce(self)
				x.mul(y)
			end
			return self
    end
    
    # Divide (element-by-element) self by other
    def div(other)
      case other
      when Numeric; GSLng.backend::gsl_blas_dscal(1.0 / other, self.ptr)
      when Vector;  GSLng.backend::gsl_vector_div(self.ptr, other.ptr)
      else
				x,y = other.coerce(self)
				x.div(y)
			end
			return self
    end

    def +(other); self.dup.add(other) end
    def -(other); self.dup.sub(other) end
    def *(other); self.dup.mul(other) end
    def /(other); self.dup.div(other) end
    
    # Reverse the order of elements
    def reverse!; GSLng.backend::gsl_vector_reverse(self.ptr); return self end
    
    # Swap the i-th element with the j-th element
    def swap(i,j); GSLng.backend::gsl_vector_swap_elements(self.ptr, i, j); return self end

		# Access the i-th element (*NOTE*: throws exception if out-of-bounds).
		# If /index/ is negative, it counts from the end (-1 is the last element)
		# TODO: support ranges
    def [](index)
			GSLng.backend::gsl_vector_get(self.ptr, (index < 0 ? @size + index : index))
    end

		# Set the i-th element (*NOTE*: throws exception if out-of-bounds)
		# If /index/ is negative, it counts from the end (-1 is the last element)
		# TODO: support ranges
    def []=(index, value)
			GSLng.backend::gsl_vector_set(self.ptr, (index < 0 ? @size + index : index), value.to_f)
    end

    # Create a Vector::View from this Vector.
    # If _size_ is nil, it is computed automatically from _offset_ and _stride_
    def view(offset = 0, size = nil, stride = 1)
      if (stride <= 0) then raise 'stride must be positive' end
      
      if (size.nil?)
        size = @size - offset
        k,m = size.divmod(stride)
        size = k + (m == 0 ? 0 : 1)
      end
      View.new(self, offset, size, stride)
    end
    alias_method :subvector, :view

    # if all elements are zero
    def zero?; GSLng.backend::gsl_vector_isnull(self.ptr) == 1 ? true : false end

    # if all elements are strictly positive (>0)
    def positive?; GSLng.backend::gsl_vector_ispos(self.ptr) == 1 ? true : false end

    #if all elements are strictly negative (<0)
    def negative?; GSLng.backend::gsl_vector_isneg(self.ptr) == 1 ? true : false end
		
    # if all elements are non-negative (>=0)
    def nonnegative?; GSLng.backend::gsl_vector_isnonneg(self.ptr) == 1 ? true : false end
    
    def max; GSLng.backend::gsl_vector_max(self.ptr) end

    def min; GSLng.backend::gsl_vector_min(self.ptr) end

		# Same as Array#minmax
    def minmax
      min = FFI::Buffer.new(:double)
      max = FFI::Buffer.new(:double)
      GSLng.backend::gsl_vector_minmax(self.ptr, min, max)
      return [min[0].get_float64(0),max[0].get_float64(0)]
    end

		# Same as #minmax, but returns the indices to the elements
    def minmax_index
      min = FFI::Buffer.new(:size_t)
      max = FFI::Buffer.new(:size_t)
      GSLng.backend::gsl_vector_minmax_index(self.ptr, min, max)
      #return [min[0].get_size_t(0),max[0].get_size_t(0)]
			return [min[0].get_ulong(0),max[0].get_ulong(0)]
    end
    
    # Same as #min, but returns the index to the element
    def min_index; GSLng.backend::gsl_vector_min_index(self.ptr) end

    # Same as #max, but returns the index to the element    
    def max_index; GSLng.backend::gsl_vector_max_index(self.ptr) end
    
    # Dot product between self and other (uses BLAS's ddot)
    def dot(other)
      out = FFI::Buffer.new(:double)
      GSLng.backend::gsl_blas_ddot(self.ptr, other.ptr, out)
      return out[0].get_double(0)
    end
    alias_method :^, :dot
    
    # Norm 2 of the vector (uses BLAS's dnrm2)
    def norm; GSLng.backend::gsl_blas_dnrm2(self.ptr) end
    alias_method :length, :norm

    # Returns the sum of all elements (uses BLAS's dasum)
    def sum; GSLng.backend::gsl_blas_dasum(self.ptr) end

    # Optimized version of: self += other * alpha (where alpha is a Numeric). Uses BLAS's daxpy.
    def mul_add(other, alpha); GSLng.backend::gsl_blas_daxpy(alpha, other.ptr, self.ptr); return self end
    
    # Yields the block for each element in the Vector
		def each # :yield: obj
			@size.times {|i| yield(self[i])}
		end

		# Efficient map! implementation
		def map!(&block); GSLng.backend::gsl_vector_map(self.ptr, block); return self end

		# Alternate version of #map!, in this case the block receives the index as a parameter.
		def map_index!(&block); GSLng.backend::gsl_vector_map_index(self.ptr, block); return self end

		# See #map!. Returns a Vector.
		def map(&block); self.dup.map!(block) end

		def sort!; GSLng.backend::gsl_sort_vector(self.ptr); return self end
		def sort; self.dup.sort! end

		def join(sep = $,)
			s = ''
			GSLng.backend::gsl_vector_each(self.ptr, lambda {|e| s += (s.empty?() ? e.to_s : sep + e.to_s)})
			return s
		end

		def coerce(other)
			if (Vector === other)
				[ other, self ]
			elsif (Numeric === other)
				[ Vector.new(@size).set!(other), self ]
			else
				raise TypeError, "Can't coerce #{other.class} into #{self.class}"
			end
		end
		
		def to_s
			"[" + self.join(', ') + "]"
		end

    def inspect
      "Vec#{self}"
    end

		def to_a
			Array.new(@size) {|i| self[i]}
		end

		# Element-by-element comparison (uses #each_with_index)
		# Admits comparing to Array
		def ==(other)
			if (self.size != other.size) then return false end
			self.each_with_index do |elem,i|
				if (elem != other[i]) then return false end
			end
			return true
		end
  end
end