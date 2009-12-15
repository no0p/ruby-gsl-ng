module GSLng
  def GSLng.set_finalizer(obj, func, ptr)
    ObjectSpace.define_finalizer(obj, lambda {|id| GSLng::Backend.send(func, ptr)})
  end
end
