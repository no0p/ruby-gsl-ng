# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$:.unshift File.join(File.dirname(__FILE__),'..','ext')

require 'test/unit'
require 'gsl'

class VectorTest < Test::Unit::TestCase
  def test_initialize
		assert_equal(10, GSL::Vector.new(10).size)
		assert_equal(10, GSL::Vector.zero(10).size)
		assert(GSL::Vector.zero(10).zero?)
		assert_nothing_raised { GSL::Vector.random(10) }
  end

	def test_to_s
		assert_equal("[0.0]", GSL::Vector.zero(1).to_s)
		assert_equal("[0.0, 0.0, 0.0]", GSL::Vector.zero(3).to_s)
		assert_equal("[0.0, 1.0, 2.0]", GSL::Vector.new(3) {|i| i}.to_s)
		assert_equal("[1.0, 2.0, 3.0]", GSL::Vector[1,2,3].to_s)
	end

	def test_equal
		assert_equal(GSL::Vector[1,2,3], [1,2,3])
		assert_equal(GSL::Vector[1,2,3], GSL::Vector[1,2,3])
		assert_equal(GSL::Vector.zero(3), GSL::Vector.zero(3))
		assert_not_equal(GSL::Vector.zero(4), GSL::Vector.zero(3))		
	end

	def test_copies
		v1 = GSL::Vector[1,2,3]
		v2 = GSL::Vector[2,3,4]
		assert_not_equal(v1, v2)
		assert_equal(v1.copy(v2), v2)
		assert_equal(v1.dup, v2)
	end

	def test_sets
		assert_equal(GSL::Vector.zero(3).set!(1), GSL::Vector[1,1,1])
		assert_equal(GSL::Vector.zero(3).set!(1).zero!, GSL::Vector.zero(3))
		assert_equal(GSL::Vector.zero(3).basis!(1), GSL::Vector[0,1,0])
	end

	def test_operators
		assert_equal(GSL::Vector[2,3,4],GSL::Vector[1,2,3] + GSL::Vector[1,1,1])
		assert_equal(GSL::Vector[1,0,3],GSL::Vector[1,2,3] * GSL::Vector[1,0,1])
		assert_equal(GSL::Vector[0,1,2],GSL::Vector[1,2,3] - GSL::Vector[1,1,1])
		assert_equal(GSL::Vector[0.5,1,1.5],GSL::Vector[1,2,3] / GSL::Vector[2,2,2])
	end

	def test_other
		assert_equal(GSL::Vector[1,2,3], GSL::Vector[1,2,3].to_a)
		assert_equal(GSL::Vector[1,2,3], GSL::Vector[3,1,2].sort)
		assert_equal(6, GSL::Vector[3,1,2].sum)
		assert_equal(GSL::Vector[3,1,2].mul_add(GSL::Vector[1,0,1],0.5), GSL::Vector[3.5,1,2.5])
		assert_equal(3, GSL::Vector[2,1,2].norm)
		assert_equal(5, GSL::Vector[3,1,2] ^ GSL::Vector[1,0,1])
	end
end
