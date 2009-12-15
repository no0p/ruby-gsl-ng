module GSLng
  class Matrix
		attr_reader :n, :m, :ptr

		alias_method :height, :n
		alias_method :width, :m
		alias_method :rows, :n
		alias_method :columns, :m

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
        Matrix.new(1, array.size) {|i,j| array[0][j]}
      else
        Matrix.new(array.size, array[0].size) {|i,j| array[i].to_a[j]}
      end
		end

		# Create a Matrix from an Array of Arrays/Ranges (see #from_array)
		def Matrix.[](*args)
      array = (!args.empty? && Range === args[0] ? args[0].to_a : args)
      Matrix.from_array(array)
		end
    
    # Generates a Matrix of n by m, of random numbers between 0 and 1.
    # NOTE: This simply uses Kernel::rand
    def Matrix.random(n, m)
			Matrix.new(n, m).map!{|x| Kernel::rand}
    end
		class << self; alias_method :rand, :random end    

		# Returns [ #rows, #columns ]
		def size
			[ @n, @m ]
		end

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
				GSLng.backend::gsl_matrix_get(@ptr, i,j)
			end
		end

		# Set the element (i,j), which means (row,column) (*NOTE*: throws exception if out-of-bounds).
		# Same indexing options as #[].
    def []=(i, j, value)
#			if (Symbol === i && Symbol === j) then
#				# TODO: coerce?
#				GSLng.backend::gsl_matrix_memcpy(@ptr, value.ptr)
#			elsif (Symbol === i)
#				col = Vector.new(@n)
#				GSLng.backend::gsl_matrix_set_col(@ptr, j, col.ptr, @ptr)
#				return col
#			elsif (Symbol === j)
#				row = Vector.new(@m)
#				GSLng.backend::gsl_matrix_set_row(@ptr, i, row.ptr)
#				return row
#			else
				GSLng.backend::gsl_matrix_set(@ptr, i, j, value)
#			end

			return self
		end

    def all!(v); GSLng.backend::gsl_matrix_set_all(@ptr, v); return self end
    alias_method :set!, :all!
    alias_method :fill!, :all!

    def zero!; GSLng.backend::gsl_matrix_set_zero(@ptr); return self end

    def identity; GSLng.backend::gsl_matrix_set_identity(@ptr); return self end
    
    # if all elements are zero
    def zero?; GSLng.backend::gsl_matrix_isnull(@ptr) == 1 ? true : false end

    # if all elements are strictly positive (>0)
    def positive?; GSLng.backend::gsl_matrix_ispos(@ptr) == 1 ? true : false end

    #if all elements are strictly negative (<0)
    def negative?; GSLng.backend::gsl_matrix_isneg(@ptr) == 1 ? true : false end
		
    # if all elements are non-negative (>=0)
    def nonnegative?; GSLng.backend::gsl_matrix_isnonneg(@ptr) == 1 ? true : false end

		# Efficient map! implementation
		def map!(&block); GSLng.backend::gsl_matrix_map(@ptr, block); return self end

		# Alternate version of #map!, in this case the block receives the index as a parameter.
		def map_index!(&block); GSLng.backend::gsl_matrix_map_index(@ptr, block); return self end

		# See #map!. Returns a Matrix.
		def map(&block); self.dup.map!(block) end
    
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
