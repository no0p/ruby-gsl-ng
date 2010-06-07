# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$:.unshift File.join(File.dirname(__FILE__),'..','ext')

require 'test/unit'
require 'gslng'
Math.extend(GSLng::Special)

class TestSpecial < Test::Unit::TestCase
  def test_trig
    assert_equal(0, Math.angle_restrict_symm(0))
    assert_equal(Math::PI, Math.angle_restrict_symm(Math::PI))
    assert_in_delta(0, Math.angle_restrict_symm(2*Math::PI),1e-15)

    assert_equal(0, Math.angle_restrict_pos(0))
    assert_equal(Math::PI, Math.angle_restrict_pos(Math::PI))
    assert_in_delta(Math::PI, Math.angle_restrict_pos(-Math::PI),1e-15)
  end
end
