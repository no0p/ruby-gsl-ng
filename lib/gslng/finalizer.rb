module GSLng
  def GSLng.set_finalizer(obj, func, ptr) # @private
    ObjectSpace.define_finalizer(obj, lambda {|id| GSLng.backend.send(func, ptr)})
  end
end
