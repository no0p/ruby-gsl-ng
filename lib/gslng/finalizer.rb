module GSLng
  def GSLng.define_finalizer(obj, func, ptr) # @private
    ObjectSpace.define_finalizer(obj, self.get_finalizer(func, ptr))
  end
  
  def GSLng.get_finalizer(func, ptr) # @private
    lambda {|id| GSLng.backend.send(func, ptr)}
  end
end
