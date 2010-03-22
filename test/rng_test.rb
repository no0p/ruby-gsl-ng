# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$:.unshift File.join(File.dirname(__FILE__),'..','ext')

require 'test/unit'
require 'gslng'
include GSLng

class RNGTest < Test::Unit::TestCase
  def test_rng
    RNG.new
  end

  def test_uniform
    three_epsilon = Vector.new(3).fill!(Float::EPSILON)
    uniform = RNG::Uniform.new(0, 2)
    assert(Vector[1.99948349781334, 0.325819750782102, 0.56523561058566] - Vector.new(3) { uniform.sample } <= three_epsilon)
  end

  def test_gaussian
    three_epsilon = Vector.new(3).fill!(Float::EPSILON)
    gaussian = RNG::Gaussian.new
    assert(Vector[0.133918608118676, -0.0881009918314384, 1.67440840625377] - Vector.new(3) { gaussian.sample } <= three_epsilon)
  end
end
