#!/usr/bin/ruby -I../lib -I../ext
require 'benchmark'
require 'gsl'
include Benchmark

N = 1000
bm do |x|
  x.report("Vector (internal each) : ") {N.times {GSL::Vector.zero(1000).all? {|e| e == 0}}}
  
  module GSL
    class Vector
      def each
        @size.times do |i| yield(self[i]) end
      end
    end
  end

  x.report("Vector (external each) : ") {N.times {GSL::Vector.zero(1000).all? {|e| e == 0}}}
end
