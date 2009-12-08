# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'gsl'

class VectorTest < Test::Unit::TestCase
  def test_initialize
		assert_nothing_raised("bleh") { GSL::Vector.new(10) }
		assert_nothing_raised() { @v = GSL::Vector.zero(10) }
		assert(@v.zero?, "Zero-initialized vector all zero?")
  end

	def test_dup
		assert_nothing_raised() { v = GSL::Vector.new(10).dup }
	end
end
