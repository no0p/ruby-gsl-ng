#!/usr/bin/ruby -I../lib
require 'benchmark'
require 'gsl'
include Benchmark

N = 10000
bm do |x|
  x.report("Ruby/GSL-ng : ") {N.times {GSL::Vector.new(100) * GSL::Vector.new(100)}}
end
