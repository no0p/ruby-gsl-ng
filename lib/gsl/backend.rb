require 'ffi'

module GSL
  # TODO:
  # * get a way to properly define the type of size_t (assumed to be :uint)
  # 
  # Wrap TODO:
  # * Vector:
  #   - Other vector types, like uint or so
  module Backend
    extend FFI::Library
    ffi_lib "libgsl.so"
    
    ##----- Vector ------##
    # memory handling
    attach_function :gsl_vector_alloc, [ :int ], :pointer
    attach_function :gsl_vector_calloc, [ :int ], :pointer
    attach_function :gsl_vector_free, [ :pointer ], :void
    
    # initializing
    attach_function :gsl_vector_set_all, [ :pointer, :double ], :void
    attach_function :gsl_vector_set_zero, [ :pointer ], :void
    attach_function :gsl_vector_set_basis, [ :pointer, :uint ], :int
  
    # operations
    attach_function :gsl_vector_add, [ :pointer, :pointer ], :int
    attach_function :gsl_vector_sub, [ :pointer, :pointer ], :int
    attach_function :gsl_vector_mul, [ :pointer, :pointer ], :int
    attach_function :gsl_vector_div, [ :pointer, :pointer ], :int
    attach_function :gsl_vector_scale, [ :pointer, :double ], :int
    attach_function :gsl_vector_add_constant, [ :pointer, :double ], :int
    
    # element access
    attach_function :gsl_vector_get, [ :pointer, :int ], :double
    attach_function :gsl_vector_set, [ :pointer, :int, :double ], :void
    
    # properties
    attach_function :gsl_vector_isnull, [ :pointer ], :int
    attach_function :gsl_vector_ispos, [ :pointer ], :int
    attach_function :gsl_vector_isneg, [ :pointer ], :int
    attach_function :gsl_vector_isnonneg, [ :pointer ], :int
    
    # max and min
    attach_function :gsl_vector_max, [ :pointer ], :double
    attach_function :gsl_vector_min, [ :pointer ], :double
    attach_function :gsl_vector_minmax, [ :pointer, :buffer_out, :buffer_out ], :void
    attach_function :gsl_vector_max_index, [ :pointer ], :uint
    attach_function :gsl_vector_min_index, [ :pointer ], :uint
    attach_function :gsl_vector_minmax_index, [ :pointer, :buffer_out, :buffer_out ], :void
    
    # copying
    attach_function :gsl_vector_memcpy, [ :pointer, :pointer ], :int
    attach_function :gsl_vector_swap, [ :pointer, :pointer ], :int
    
    # exchanging elements
    attach_function :gsl_vector_swap_elements, [ :pointer, :uint, :uint ], :int
    attach_function :gsl_vector_reverse, [ :pointer ], :int
    
    # BLAS functions
    attach_function :gsl_blas_ddot, [ :pointer, :pointer, :buffer_out ], :int
    attach_function :gsl_blas_dnrm2, [ :pointer ], :double
    attach_function :gsl_blas_dasum, [ :pointer ], :double
    #attach_function :gsl_blas_idamax, [ :pointer ], clbas_index??
    #attach_function :gsl_blas_dcopy, use this instead of memcpy?
    attach_function :gsl_blas_daxpy, [ :double, :pointer, :pointer ], :int
    attach_function :gsl_blas_dscal, [ :double, :pointer ], :void
    
    ##----- Error handling ------##
    callback :error_handler_callback, [ :string, :string, :int, :int ], :void
    attach_function :gsl_set_error_handler, [ :error_handler_callback ], :error_handler_callback
    
    # TODO: pop this block from the exception stack so that it seems to be coming from the original gsl function
    ErrorHandlerCallback = Proc.new {|reason, file, line, errno|
      raise RuntimeError, "#{reason} at #{file}:#{line} (errno: #{errno})"      
    }
    gsl_set_error_handler(ErrorHandlerCallback)
  end
end
