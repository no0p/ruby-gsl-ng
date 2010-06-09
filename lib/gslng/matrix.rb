module GSLng
  # A fixed-size MxN matrix.
  #
  # =Notes
  # See Vector notes. Everything applies with the following *differences/additions*:
  # * The {#*} operator performs actual matrix-matrix and matrix-vector products. To perform element-by-element
  #   multiplication use the {#^} operator (or {#multiply} method) instead. The rest of the operators work element-by-element.
  # * Operators can handle matrix-matrix, matrix-vector and matrix-scalar (also in reversed order). See {#coerce}.
  # * The {#[]} and {#[]=} operators can handle a "wildcard" value for any dimension, just like MATLAB's colon (:).
  class Matrix
    attr_reader :m, :n    
    attr_reader :ptr # @private

    alias_method :height, :m
    alias_method :width, :n
    alias_method :rows, :m
    alias_method :columns, :n

    # Shorthand for [{#rows},{#columns}]
    def size; [ @m, @n ] end

    #--------------------- constructors -------------------------#

    # Create a Matrix of m-by-n (rows and columns). If zero is true, the Matrix is initialized with zeros.
    # Otherwise, the Matrix will contain garbage.
    # You can optionally pass a block, in which case {#map_index!} will be called with it (i.e.: it works like Array.new).
    def initialize(m, n, zero = false)
      @ptr = (zero ? GSLng.backend::gsl_matrix_calloc(m, n) : GSLng.backend::gsl_matrix_alloc(m, n))
      GSLng.define_finalizer(self, :gsl_matrix_free, @ptr)

      @m,@n = m,n
      if (block_given?) then self.map_index!(Proc.new) end
    end

    def initialize_copy(other) # @private
      ObjectSpace.undefine_finalizer(self) # TODO: ruby bug?
      @ptr = GSLng.backend::gsl_matrix_alloc(other.m, other.n)
      GSLng.define_finalizer(self, :gsl_matrix_free, @ptr)

      @m,@n = other.size
      GSLng.backend::gsl_matrix_memcpy(@ptr, other.ptr)
    end

    # Same as Matrix.new(m, n, true)
    def Matrix.zero(m, n); Matrix.new(m, n, true) end

    # Create a matrix from an Array
    # @see Matrix::[]
    def Matrix.from_array(array)
      if (array.empty?) then raise "Can't create empty matrix" end

      if (Numeric === array[0]) then
        Matrix.new(1, array.size) {|i,j| array[j]}
      else
        Matrix.new(array.size, array[0].to_a.size) {|i,j| array[i].to_a[j]}
      end
    end

    # Create a Matrix from an Array/Array of Arrays/Range
    # @example
    #  Matrix[[1,2],[3,4]] => [1.0 2.0; 3.0 4.0]:Matrix
    #  Matrix[1,2,3] => [1.0 2.0 3.0]:Matrix
    #  Matrix[[1..3],[5..7]] => [1.0 2.0 3.0; 5.0 6.0 7.0]:Matrix
    # @see Matrix::from_array    
    def Matrix.[](*args)
      Matrix.from_array(args)
    end
    
    # Generates a Matrix of m by n, of random numbers between 0 and 1.
    # NOTE: This simply uses {Kernel::rand}
    def Matrix.random(m, n)
      Matrix.new(m, n).map!{|x| Kernel::rand}
    end
    class << self; alias_method :rand, :random end

    #--------------------- setting values -------------------------#

    # Set all values to _v_
    def all!(v); GSLng.backend::gsl_matrix_set_all(@ptr, v); return self end
    alias_method :set!, :all!
    alias_method :fill!, :all!

    # Set all values to zero
    def zero!; GSLng.backend::gsl_matrix_set_zero(@ptr); return self end

    # Set the identity matrix values
    def identity; GSLng.backend::gsl_matrix_set_identity(@ptr); return self end

    #--------------------- set/get -------------------------#

    # Access the element (i,j), which means (row,column).
    # Symbols :* or :all can be used as wildcards for both dimensions.
    # @example If +m = Matrix[[1,2],[3,4]]+
    #  m[0,0] => 1.0
    #  m[0,:*] => [1.0, 2.0]:Matrix
    #  m[:*,0] => [1.0, 3.0]:Matrix
    #  m[:*,:*] => [1.0, 2.0; 3.0, 4.0]:Matrix
    # @raise [RuntimeError] if out-of-bounds
    # @return [Numeric,Matrix] the element/sub-matrix
    def [](i, j = :*)
      if (Symbol === i && Symbol === j) then return self
      elsif (Symbol === i)
        col = Vector.new(@m)
        GSLng.backend::gsl_matrix_get_col(col.ptr, @ptr, j)
        return col.to_matrix
      elsif (Symbol === j)
        row = Vector.new(@n)
        GSLng.backend::gsl_matrix_get_row(row.ptr, @ptr, i)
        return row.to_matrix
      else
        GSLng.backend::gsl_matrix_get(@ptr, i, j)
      end
    end

    # Set the element (i,j), which means (row,column).
    # @param [Numeric,Vector,Matrix] value depends on indexing
    # @raise [RuntimeError] if out-of-bounds
    # @see #[]
    def []=(i, j, value)
      if (Symbol === i && Symbol === j) then
        if (Numeric === value) then self.fill!(value)
        else
          x,y = self.coerce(value)
          GSLng.backend::gsl_matrix_memcpy(@ptr, x.ptr)
        end
      elsif (Symbol === i)
        col = Vector.new(@m)
        x,y = col.coerce(value)
        GSLng.backend::gsl_matrix_set_col(@ptr, j, x.ptr)
        return col
      elsif (Symbol === j)
        row = Vector.new(@n)
        x,y = row.coerce(value)
        GSLng.backend::gsl_matrix_set_row(@ptr, i, x.ptr)
        return row
      else
        GSLng.backend::gsl_matrix_set(@ptr, i, j, value)
      end

      return self
    end

    #--------------------- view -------------------------#

    # Create a {Matrix::View} from this Matrix.
    # If either _m_ or _n_ are nil, they're computed from _x_, _y_ and the Matrix's {#size}
    # @return [Matrix::View]
    def view(x = 0, y = 0, m = nil, n = nil)
      View.new(self, x, y, (m or @m - x), (n or @n - y))
    end
    alias_method :submatrix_view, :view
    
    # Shorthand for #submatrix_view(..).to_matrix.
    # @return [Matrix]
    def submatrix(*args); self.submatrix_view(*args).to_matrix end

    # Creates a {Matrix::View} for the i-th column
    # @return [Matrix::View]
    def column_view(i, offset = 0, size = nil); self.view(offset, i, (size or (@m - offset)), 1) end

    # Analogous to {#submatrix}
    # @return [Matrix]
    def column(*args); self.column_view(*args).to_matrix end

    # Creates a {Matrix::View} for the i-th row
    # @return [Matrix::View]
    def row_view(i, offset = 0, size = nil); self.view(i, offset, 1, (size or (@n - offset))) end

    # Analogous to {#submatrix}
    # @return [Matrix]
    def row(*args); self.row_view(*args).to_matrix end

    # Same as {#row_view}, but returns a {Vector::View}
    # @return [Vector::View]
    def row_vecview(i, offset = 0, size = nil)
      size = (@n - offset) if size.nil?
      ptr = GSLng.backend.gsl_matrix_row_view(self.ptr, i, offset, size)
      Vector::View.new(ptr, self, offset, size)
    end

    # Same as {#column_view}, but returns a {Vector::View}
    # @return [Vector::View]
    def column_vecview(i, offset = 0, size = nil)
      size = (@m - offset) if size.nil?
      ptr = GSLng.backend.gsl_matrix_column_view(self.ptr, i, offset, size)
      Vector::View.new(ptr, self, offset, size)
    end

    
    #--------------------- operators -------------------------#

    # Add other to self
    # @return [Matrix] self
    def add!(other)
      case other
      when Numeric; GSLng.backend::gsl_matrix_add_constant(self.ptr, other.to_f)
      when Matrix; GSLng.backend::gsl_matrix_add(self.ptr, other.ptr)
      else
        x,y = other.coerce(self)
        x.add!(y)
      end
      return self
    end

    # Substract other from self
    # @return [Matrix] self    
    def substract!(other)
      case other
      when Numeric; GSLng.backend::gsl_matrix_add_constant(self.ptr, -other.to_f)
      when Matrix; GSLng.backend::gsl_matrix_sub(self.ptr, other.ptr)
      else
        x,y = other.coerce(self)
        x.substract!(y)
      end
      return self
    end
    alias_method :sub!, :substract!

    # Multiply (element-by-element) other with self
    # @return [Matrix] self    
    def multiply!(other)
      case other
      when Numeric; GSLng.backend::gsl_matrix_scale(self.ptr, other.to_f)
      when Matrix; GSLng.backend::gsl_matrix_mul_elements(self.ptr, other.ptr)
      else
        x,y = other.coerce(self)
        x.multiply!(y)
      end
      return self
    end
    alias_method :mul!, :multiply!

    # Divide (element-by-element) self by other
    # @return [Matrix] self    
    def divide!(other)
      case other
      when Numeric; GSLng.backend::gsl_matrix_scale(self.ptr, 1.0 / other)
      when Matrix;  GSLng.backend::gsl_matrix_div_elements(self.ptr, other.ptr)
      else
        x,y = other.coerce(self)
        x.divide!(y)
      end
      return self
    end
    alias_method :div!, :divide!

    # Element-by-element addition
    def +(other); self.dup.add!(other) end

    # Element-by-element substraction
    def -(other); self.dup.substract!(other) end

    # Element-by-element division
    def /(other); self.dup.divide!(other) end

    # Element-by-element product. Both matrices should have same dimensions.
    def ^(other); self.dup.multiply!(other) end
    alias_method :multiply, :^
    alias_method :mul, :^

    # Matrix Product. self.n should equal other.m (or other.size, if a Vector).
    # @example
    #  Matrix[[1,2],[2,3]] * 2 => [2.0 4.0; 4.0 6.0]:Matrix
    # @todo some cases could be optimized when doing Matrix-Matrix, by using dgemv
    def *(other)
      case other
      when Numeric
        self.multiply(other)
      when Vector
        matrix = Matrix.new(self.m, other.size)
        GSLng.backend::gsl_blas_dgemm(:no_transpose, :no_transpose, 1, self.ptr, other.to_matrix.ptr, 0, matrix.ptr)
        return matrix
      when Matrix
        matrix = Matrix.new(self.m, other.n)
        GSLng.backend::gsl_blas_dgemm(:no_transpose, :no_transpose, 1, self.ptr, other.ptr, 0, matrix.ptr)
        return matrix
      else
        x,y = other.coerce(self)
        x * y
      end
    end

    #--------------------- swap rows/columns -------------------------#

    # Transposes in-place. Only for square matrices
    def transpose!; GSLng.backend::gsl_matrix_transpose(self.ptr); return self end

    # Returns the transpose of self, in a new matrix
    def transpose; matrix = Matrix.new(@n, @m); GSLng.backend::gsl_matrix_transpose_memcpy(matrix.ptr, self.ptr); return matrix end

    # Swap the i-th and j-th columnos
    def swap_columns(i, j); GSLng.backend::gsl_matrix_swap_columns(self.ptr, i, j); return self end
    
    # Swap the i-th and j-th rows
    def swap_rows(i, j); GSLng.backend::gsl_matrix_swap_rows(self.ptr, i, j); return self end
    
    # Swap the i-th row with the j-th column. The Matrix must be square.
    def swap_rowcol(i, j); GSLng.backend::gsl_matrix_swap_rowcol(self.ptr, i, j); return self end

    #--------------------- predicate methods -------------------------#
    
    # if all elements are zero
    def zero?; GSLng.backend::gsl_matrix_isnull(@ptr) == 1 ? true : false end

    # if all elements are strictly positive (>0)
    def positive?; GSLng.backend::gsl_matrix_ispos(@ptr) == 1 ? true : false end

    #if all elements are strictly negative (<0)
    def negative?; GSLng.backend::gsl_matrix_isneg(@ptr) == 1 ? true : false end
    
    # if all elements are non-negative (>=0)
    def nonnegative?; GSLng.backend::gsl_matrix_isnonneg(@ptr) == 1 ? true : false end

    # If this is a column Matrix
    def column?; self.columns == 1 end

    #--------------------- min/max -------------------------#

    # Maximum element of the Matrix
    def max; GSLng.backend::gsl_matrix_max(self.ptr) end

    # Minimum element of the Matrix
    def min; GSLng.backend::gsl_matrix_min(self.ptr) end

    # Same as {Array#minmax}
    def minmax
      min = FFI::Buffer.new(:double)
      max = FFI::Buffer.new(:double)
      GSLng.backend::gsl_matrix_minmax(self.ptr, min, max)
      return [min[0].get_float64(0),max[0].get_float64(0)]
    end

    # Same as {#minmax}, but returns the indices to the i-th and j-th min, and i-th and j-th max.
    def minmax_index
      i_min = FFI::Buffer.new(:size_t)
      j_min = FFI::Buffer.new(:size_t)
      i_max = FFI::Buffer.new(:size_t)
      j_max = FFI::Buffer.new(:size_t)
      GSLng.backend::gsl_matrix_minmax_index(self.ptr, i_min, j_min, i_max, j_max)
      #return [min[0].get_size_t(0),max[0].get_size_t(0)]
      return [i_min[0].get_ulong(0),j_min[0].get_ulong(0),i_max[0].get_ulong(0),j_max[0].get_ulong(0)]
    end

    # Same as {#min}, but returns the indices to the i-th and j-th minimum elements
    def min_index
      i_min = FFI::Buffer.new(:size_t)
      j_min = FFI::Buffer.new(:size_t)
      GSLng.backend::gsl_matrix_min_index(self.ptr, i_min, j_min)
      return [i_min[0].get_ulong(0), j_min[0].get_ulong(0)]
    end

    # Same as {#max}, but returns the indices to the i-th and j-th maximum elements
    def max_index
      i_max = FFI::Buffer.new(:size_t)
      j_max = FFI::Buffer.new(:size_t)
      GSLng.backend::gsl_matrix_max_index(self.ptr, i_max, j_max)
      return [i_max[0].get_ulong(0), j_max[0].get_ulong(0)]
    end

    #--------------------- block handling -------------------------#

    # Yields the specified block for each element going row-by-row
    # @yield [elem]
    def each 
      @m.times {|i| @n.times {|j| yield(self[i,j]) } }
    end

    # Yields the specified block for each element going row-by-row
    # @yield [elem, i, j]
    def each_with_index 
      @m.times {|i| @n.times {|j| yield(self[i,j], i, j) } }
    end

    # Same as {#each}, but faster. The catch is that this method returns nothing.
    # @yield [elem]
    # @return [void]
    def fast_each(block = Proc.new) 
      GSLng.backend::gsl_matrix_each(self.ptr, block)
    end
    
    # @see #each
    # @yield [elem,i,j]
    def fast_each_with_index(block = Proc.new) 
      GSLng.backend::gsl_matrix_each_with_index(self.ptr, block)
    end    

    # Yields the block for each row *view* ({Matrix::View}).
    # @yield [view]
    def each_row; self.rows.times {|i| yield(row_view(i))} end

    # Same as {#each_row}, but yields {Vector::View}'s
    # @yield [vector_view]    
    def each_vec_row; self.rows.times {|i| yield(row_vecview(i))} end

    # Same as #each_column, but yields {Vector::View}'s
    # @yield [vector_view]    
    def each_vec_column; self.columns.times {|i| yield(column_vecview(i))} end

    # Yields the block for each column *view* ({Matrix::View}).
    # @yield [view]    
    def each_column; self.columns.times {|i| yield(column_view(i))} end

    # Efficient {#map!} implementation
    # @yield [elem]
    def map!(block = Proc.new); GSLng.backend::gsl_matrix_map(@ptr, block); return self end

    # Alternate version of {#map!}, in this case the block receives the index (row, column) as a parameter.
    # @yield [i,j]
    def map_index!(block = Proc.new); GSLng.backend::gsl_matrix_map_index(@ptr, block); return self end

    # Similar to {#map_index!}, in this case it receives both the element and the index to it
    # @yield [elem,i,j]
    def map_with_index!(block = Proc.new); GSLng.backend::gsl_matrix_map_with_index(@ptr, block); return self end

    # @see #map!
    # @return [Matrix]
    # @yield [elem]
    def map(block = Proc.new); self.dup.map!(block) end

    #--------------------- conversions -------------------------#

    # Same as {Array#join}
    # @example
    #  Matrix[[1,2],[2,3]].join => "1.0 2.0 2.0 3.0"
    def join(sep = $,)
      s = ''
      GSLng.backend::gsl_matrix_each(@ptr, lambda {|e| s += (s.empty?() ? e.to_s : "#{sep}#{e}")})
      return s
    end

    # Converts the matrix to a String, separating each element with a space and each row with a ';' and a newline.
    # @example
    #  Matrix[[1,2],[2,3]] => "[1.0 2.0;\n 2.0 3.0]"
    def to_s
      s = '['
      @m.times do |i|
        s += ' ' unless i == 0
        @n.times do |j|
          s += (j == 0 ? self[i,j].to_s : ' ' + self[i,j].to_s)
        end
        s += (i == (@m-1) ? ']' : ";\n")
      end

      return s
    end
    
    # Converts the matrix to an Array (of Arrays).
    # @example
    #  Matrix[[1,2],[2,3]] => [[1.0,2.0],[2.0,3.0]]
    def to_a
      a = Array.new(self.m) {|i| Array.new(self.n)}
      self.fast_each_with_index {|e,i,j| a[i][j] = e}
      return a
    end

    def inspect # @private
      "#{self}:Matrix"
    end

    # Coerces _other_ to be of Matrix class.
    # If _other_ is a scalar (Numeric) a Matrix filled with _other_ values is created.
    # Vectors are coerced using {Vector#to_matrix} (which results in a row matrix).
    def coerce(other)
      case other
      when Matrix
        [ other, self ]
      when Numeric
        [ Matrix.new(@m, @n).fill!(other), self ]
      when Vector
        [ other.to_matrix, self ]
      else
        raise TypeError, "Can't coerce #{other.class} into #{self.class}"
      end
    end

    #--------------------- equality -------------------------#

    # Element-by-element comparison.
    def ==(other)
      if (self.m != other.m || self.n != other.n) then return false end

      @m.times do |i|
        @n.times do |j|
          if (self[i,j] != other[i,j]) then return false end
        end
      end
      
      return true
    end
  end
end
