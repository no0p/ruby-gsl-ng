module GSLng
  class Matrix
		attr_reader :n, :m, :ptr

		alias_method :height, :n
		alias_method :width, :m
		alias_method :rows, :n
		alias_method :columns, :m

		# Returns [ #rows, #columns ]
		def size; [ @n, @m ] end

    #--------------------- constructors -------------------------#

		# Create a Matrix of n-by-m (rows and columns). If zero is true, the Matrix is initialized with zeros.
    # Otherwise, the Matrix will contain garbage.
		# You can optionally pass a block, in which case #map_index! will be called with it (i.e.: it works like Array.new).
    def initialize(n, m, zero = false)
      @ptr = (zero ? GSLng.backend::gsl_matrix_calloc(n, m) : GSLng.backend::gsl_matrix_alloc(n, m))
      GSLng.set_finalizer(self, :gsl_matrix_free, @ptr)

      @n,@m = n,m
			if (block_given?) then self.map_index!(&Proc.new) end
    end

    def initialize_copy(other) #:nodoc:
      ObjectSpace.undefine_finalizer(self) # TODO: ruby bug?
      @ptr = GSLng.backend::gsl_matrix_alloc(other.n, other.m)
      GSLng.set_finalizer(self, :gsl_matrix_free, @ptr)

      @n,@m = other.size
      GSLng.backend::gsl_matrix_memcpy(@ptr, other.ptr)
    end

		# Same as Matrix.new(n, m, true)
		def Matrix.zero(n, m); Matrix.new(n, m, true) end

		# Create a matrix from an Array
    # If array is unidimensional, a row Matrix is created. If it is multidimensional, each sub-array
    # corresponds to a row of the resulting Matrix. Also, _array_ can be an Array of Ranges, in which case
    # each Range will correspond to a row.
		def Matrix.from_array(array)
			if (array.empty?) then raise "Can't create empty matrix" end

      if (Numeric === array[0]) then
        Matrix.new(1, array.size) {|i,j| array[j]}
      else
        Matrix.new(array.size, array[0].to_a.size) {|i,j| array[i].to_a[j]}
      end
		end

		# Create a Matrix from an Array of Arrays/Ranges (see #from_array)
		def Matrix.[](*args)
      Matrix.from_array(args)
		end
    
    # Generates a Matrix of n by m, of random numbers between 0 and 1.
    # NOTE: This simply uses Kernel::rand
    def Matrix.random(n, m)
			Matrix.new(n, m).map!{|x| Kernel::rand}
    end
		class << self; alias_method :rand, :random end

    #--------------------- setting values -------------------------#

    def all!(v); GSLng.backend::gsl_matrix_set_all(@ptr, v); return self end
    alias_method :set!, :all!
    alias_method :fill!, :all!

    def zero!; GSLng.backend::gsl_matrix_set_zero(@ptr); return self end

    def identity; GSLng.backend::gsl_matrix_set_identity(@ptr); return self end

    #--------------------- set/get -------------------------#

		# Access the element (i,j), which means (row,column) (*NOTE*: throws exception if out-of-bounds).
		# If either i or j are :* or :all, it serves as a wildcard for that dimension, returning all rows or columns,
		# respectively.
    def [](i, j = :*)
			if (Symbol === i && Symbol === j) then return self
			elsif (Symbol === i)
				col = Vector.new(@n)
				GSLng.backend::gsl_matrix_get_col(col.ptr, @ptr, j)
				return col
			elsif (Symbol === j)
				row = Vector.new(@m)
				GSLng.backend::gsl_matrix_get_row(row.ptr, @ptr, i)
				return row
			else
				GSLng.backend::gsl_matrix_get(@ptr, i, j)
			end
		end

		# Set the element (i,j), which means (row,column) (*NOTE*: throws exception if out-of-bounds).
		# Same indexing options as #[].
    # _value_ can be a single Numeric, a Vector or a Matrix, depending on the indexing.
    def []=(i, j, value)
			if (Symbol === i && Symbol === j) then
				if (Numeric === value) then self.fill!(value)
        else
          x,y = self.coerce(value)
          GSLng.backend::gsl_matrix_memcpy(@ptr, x.ptr)
        end
			elsif (Symbol === i)
				col = Vector.new(@n)
        x,y = col.coerce(value)
				GSLng.backend::gsl_matrix_set_col(@ptr, j, x.ptr)
				return col
			elsif (Symbol === j)
  			row = Vector.new(@m)
        x,y = row.coerce(value)
				GSLng.backend::gsl_matrix_set_row(@ptr, i, x.ptr)
				return row
			else
				GSLng.backend::gsl_matrix_set(@ptr, i, j, value)
			end

			return self
		end

    #--------------------- operators -------------------------#
    # Add other to self
    def add(other)
      case other
      when Numeric; GSLng.backend::gsl_matrix_add_constant(self.ptr, other.to_f)
      when Matrix; GSLng.backend::gsl_matrix_add(self.ptr, other.ptr)
      else
				x,y = other.coerce(self)
				x.add(y)
			end
			return self
    end

    # Substract other from self
    def sub(other)
      case other
      when Numeric; GSLng.backend::gsl_matrix_add_constant(self.ptr, -other.to_f)
      when Matrix; GSLng.backend::gsl_matrix_sub(self.ptr, other.ptr)
      else
				x,y = other.coerce(self)
				x.sub(y)
			end
			return self
    end

    # Multiply (element-by-element) other with self
    def mul(other)
      case other
      when Numeric; GSLng.backend::gsl_matrix_scale(other.to_f, self.ptr)
      when Matrix; GSLng.backend::gsl_matrix_mul_elements(self.ptr, other.ptr)
      else
				x,y = other.coerce(self)
				x.mul(y)
			end
			return self
    end

    # Divide (element-by-element) self by other
    def div(other)
      case other
      when Numeric; GSLng.backend::gsl_matrix_scale(1.0 / other, self.ptr)
      when Matrix;  GSLng.backend::gsl_matrix_div_elements(self.ptr, other.ptr)
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

    #--------------------- misc -------------------------#

    # Transposes in-place. Only for square matrices
    def transpose!; GSLng.backend::gsl_matrix_transpose(self.ptr); return self end

    # Returns the transpose of self, in a new matrix
    def transpose; m = Matrix.new(@m, @n); GSLng.backend::gsl_matrix_transpose_memcpy(m.ptr, self.ptr); return m end

    #--------------------- predicate methods -------------------------#
    
    # if all elements are zero
    def zero?; GSLng.backend::gsl_matrix_isnull(@ptr) == 1 ? true : false end

    # if all elements are strictly positive (>0)
    def positive?; GSLng.backend::gsl_matrix_ispos(@ptr) == 1 ? true : false end

    #if all elements are strictly negative (<0)
    def negative?; GSLng.backend::gsl_matrix_isneg(@ptr) == 1 ? true : false end
		
    # if all elements are non-negative (>=0)
    def nonnegative?; GSLng.backend::gsl_matrix_isnonneg(@ptr) == 1 ? true : false end

    #--------------------- min/max -------------------------#

    def max; GSLng.backend::gsl_matrix_max(self.ptr) end

    def min; GSLng.backend::gsl_matrix_min(self.ptr) end

    # Same as Array#minmax
    def minmax
      min = FFI::Buffer.new(:double)
      max = FFI::Buffer.new(:double)
      GSLng.backend::gsl_matrix_minmax(self.ptr, min, max)
      return [min[0].get_float64(0),max[0].get_float64(0)]
    end

		# Same as #minmax, but returns the indices to the i-th and j-th min, and i-th and j-th max.
    def minmax_index
      i_min = FFI::Buffer.new(:size_t)
      j_min = FFI::Buffer.new(:size_t)
      i_max = FFI::Buffer.new(:size_t)
      j_max = FFI::Buffer.new(:size_t)
      GSLng.backend::gsl_matrix_minmax_index(self.ptr, i_min, j_min, i_max, j_max)
      #return [min[0].get_size_t(0),max[0].get_size_t(0)]
			return [i_min[0].get_ulong(0),j_min[0].get_ulong(0),i_max[0].get_ulong(0),j_max[0].get_ulong(0)]
    end

    # Same as #min, but returns the indices to the i-th and j-th minimum elements
    def min_index
      i_min = FFI::Buffer.new(:size_t)
      j_min = FFI::Buffer.new(:size_t)
      GSLng.backend::gsl_matrix_min_index(self.ptr, i_min, j_min)
      return [i_min[0].get_ulong(0), j_min[0].get_ulong(0)]
    end

    # Same as #max, but returns the indices to the i-th and j-th maximum elements
    def max_index
      i_max = FFI::Buffer.new(:size_t)
      j_max = FFI::Buffer.new(:size_t)
      GSLng.backend::gsl_matrix_max_index(self.ptr, i_max, j_max)
      return [i_max[0].get_ulong(0), j_max[0].get_ulong(0)]
    end

    #--------------------- block handling -------------------------#

		# Efficient map! implementation
		def map!(&block); GSLng.backend::gsl_matrix_map(@ptr, block); return self end

		# Alternate version of #map!, in this case the block receives the index as a parameter.
		def map_index!(&block); GSLng.backend::gsl_matrix_map_index(@ptr, block); return self end

		# See #map!. Returns a Matrix.
		def map(&block); self.dup.map!(block) end

    #--------------------- conversions -------------------------#
    
    def join(sep = $,)
			s = ''
			GSLng.backend::gsl_matrix_each(@ptr, lambda {|e| s += (s.empty?() ? e.to_s : sep + e.to_s)})
			return s
		end

    # TODO: make it faster
		def to_s
      s = '['
      @n.times do |i|
        s += ' ' unless i == 0
        @m.times do |j|
          s += (j == 0 ? self[i,j].to_s : ' ' + self[i,j].to_s)
        end
        s += (i == (@n-1) ? ']' : ";\n")
      end

      return s
		end
    alias_method :inspect, :to_s

    def coerce(other)
      case other
      when Matrix
        [ other, self ]
      when Numeric
        [ Matrix.new(@n, @m).fill!(other), self ]
      else
        raise TypeError, "Can't coerce #{other.class} into #{self.class}"
      end
    end

    #--------------------- equality -------------------------#

    # TODO: make it faster
    def ==(other)
      if (self.n != other.n || self.m != other.m) then return false end

      @n.times do |i|
        @m.times do |j|
          if (self[i,j] != other[i,j]) then return false end
        end
      end
      
      return true
    end
  end
end
