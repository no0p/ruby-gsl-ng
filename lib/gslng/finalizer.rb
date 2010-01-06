module GSLng
  def GSLng.set_finalizer(obj, func, ptr) #:nodoc:
    ObjectSpace.define_finalizer(obj, lambda {|id| GSLng.backend.send(func, ptr)})
  end
end
