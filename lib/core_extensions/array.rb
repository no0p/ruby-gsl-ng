# 
# Convenience extensions for core array
#
class Array

  def to_v
    GSLng::Vector.from_array self
  end

  def to_m
    GSLng::Matrix.from_array self
  end

end
