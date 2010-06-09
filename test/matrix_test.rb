$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$:.unshift File.join(File.dirname(__FILE__),'..','ext')

require 'test/unit'
require 'gslng'

include GSLng

class TestMatrix < Test::Unit::TestCase
  def test_initialize
		assert_equal([5,5], Matrix.new(5,5).size)
		assert_equal([5,5], Matrix.zero(5,5).size)
		assert(Matrix.zero(5,5).zero?)
		assert_nothing_raised { Matrix.random(5,5) }
	end

  def test_to_s
    assert_equal("[0.0 0.0 0.0]", Matrix[0, 0, 0].to_s)
    assert_equal("[0.0 1.0 2.0]", Matrix[0,1,2].to_s)
    assert_equal("[1.0 2.0 3.0;\n 2.0 3.0 4.0]", Matrix[[1,2,3],[2,3,4]].to_s)
    assert_equal("0.0 0.0 0.0", Matrix[0, 0, 0].join(' '))
    assert_equal("1.0 2.0 3.0 2.0 3.0 4.0", Matrix[[1,2,3],[2,3,4]].join(' '))
  end
  
  def test_to_a
    assert_equal([[0.0, 0.0, 0.0]], Matrix[0, 0, 0].to_a)
    assert_equal([[0.0, 1.0, 2.0]], Matrix[0,1,2].to_a)
    assert_equal([[1.0, 2.0, 3.0],[2.0, 3.0, 4.0]], Matrix[[1,2,3],[2,3,4]].to_a)
  end

  def test_equal
    assert_equal(Matrix[0, 0, 0], Matrix[0, 0, 0])
    assert_equal(Matrix[[1,2,3],[2,3,4]], Matrix[[1,2,3],[2,3,4]])
    m = Matrix[[1,2,3],[2,3,4]]
    assert_equal(m, m.dup)
    assert_equal(Matrix[0,1,2], Matrix[0...3])
    assert_equal(Matrix[[0,1,2],[1,2,3]], Matrix[0...3,1...4])
  end

	def test_set_get
    m = Matrix[[1,2,3],[2,3,4]]
    m[0,0] = 3
    assert_equal(Matrix[[3,2,3],[2,3,4]], m)
    assert_equal(2, m[1,0])
	end

  def test_each
    m = Matrix[[1,2,3],[3,4,5]]
    a = []
    m.each {|e| a << e}
    assert_equal([1,2,3,3,4,5], a)
    a = []
    m.each {|e| a << e}
    assert_equal([1,2,3,3,4,5], a)
    a = []
    m.each_row {|r| r.each {|e| a << e}}
    assert_equal([1,2,3,3,4,5], a)
    a = []
    m.each_column {|c| c.each {|e| a << e}}
    assert_equal([1,3,2,4,3,5], a)
    a = []
    m.each_vec_row {|r| r.each {|e| a << e}}
    assert_equal([1,2,3,3,4,5], a)
    a = []
    m.each_vec_column {|c| c.each {|e| a << e}}
    assert_equal([1,3,2,4,3,5], a)
  end

  def test_complex_get
    m = Matrix[[1,2,3],[2,3,4]]
    assert_equal(m, m[:*,:*])
    assert_equal(Matrix[1, 2, 3], m[0,:*])
    assert_equal(Matrix[2, 3, 4], m[1,:*])
    assert_equal(Matrix[1, 2], m[:*,0])
    assert_equal(Matrix[2, 3], m[:*,1])
    assert_equal(Matrix[3, 4], m[:*,2])
  end

  def test_complex_set
    m = Matrix[[1,2,3],[2,3,4]]
    m[0,:*] = 1
    assert_equal(Matrix[[1,1,1],[2,3,4]], m)
    m[0,:*] = Vector[1,2,4]
    assert_equal(Matrix[[1,2,4],[2,3,4]], m)

    m[:*,0] = 1
    assert_equal(Matrix[[1,2,4],[1,3,4]], m)
    m[:*,0] = Vector[1,2]
    assert_equal(Matrix[[1,2,4],[2,3,4]], m)

    m[:*,:*] = 1
    assert_equal(Matrix[[1,1,1],[1,1,1]], m)
  end

	def test_operators
		assert_equal(Matrix[[1,4,3],[2,4,4]],Matrix[[1,2,3],[2,3,4]] + Matrix[[0,2,0],[0,1,0]])
    assert_equal(Matrix[[1.5,2.5,3.5],[2.5,3.5,4.5]],Matrix[[1,2,3],[2,3,4]] + 0.5)
    assert_equal(Matrix[[1.5,2.5,3.5],[2.5,3.5,4.5]],0.5 + Matrix[[1,2,3],[2,3,4]])

    assert_equal(Matrix[[0,2,0],[0,4,0],[0,6,0]],Matrix[1,2,3].transpose * Vector[0,2,0])
    assert_equal(Matrix[[4],[6]],Matrix[[1,2,3],[2,3,4]] * Vector[0,2,0].transpose)
    assert_equal(Matrix[4, 6],Vector[0,2,0] * Matrix[[1,2],[2,3],[4,5]])
    assert_equal(Matrix[[3,6],[9,12]],Matrix[[1,2],[3,4]] * 3)

    assert_equal(Matrix[[4,6],[2,3]],Matrix[[0,2,0],[0,1,0]] * Matrix[[1,2],[2,3],[4,5]])
    assert_equal(Matrix[[0,4,0],[0,1,0]],Matrix[[0,2,0],[0,1,0]] ^ Matrix[[0,2,0],[0,1,0]])
	end

  def test_swaps
    m = Matrix[[1,2,3],[2,3,4],[3,4,5]]
    assert_equal(Matrix[[2,3,4],[1,2,3],[3,4,5]], m.swap_rows(0,1))
    assert_equal(Matrix[[3,2,4],[2,1,3],[4,3,5]], m.swap_columns(0,1))
    assert_equal(Matrix[[3,2,4],[2,1,3],[4,3,5]], m.swap_rowcol(0,0))
  end

  def test_view
    m,view = nil,nil
    assert_nothing_raised {
      m = Matrix[[1,2,3],[2,3,4]]
      view = m.view
      view[0,0] = 3
    }
    assert_equal(Matrix[[3,2,3],[2,3,4]], m)
    assert_equal(Matrix[[3,2,3],[2,3,4]], view)
    assert_equal(Matrix[3,4], m.view(1, 1))
    assert_equal(Matrix[3,2], m.view(0, 0, nil, 1).transpose)
    assert_equal(Matrix[[3],[2]], m.column_view(0))
    assert_equal(Matrix[3,2,3], m.row_view(0))
  end
end
