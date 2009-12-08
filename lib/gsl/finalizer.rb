module GSL
  def GSL.set_finalizer(obj, func, ptr)
    ObjectSpace.define_finalizer(obj, lambda {|id| GSL::Backend.send(func, ptr)})
  end
end
