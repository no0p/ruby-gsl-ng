#!/usr/bin/ruby -I../lib -I../ext
require 'benchmark'
require 'gslng'
require 'rbgsl'
require 'narray'
include Benchmark

def my_join(v)
  s = ' '
  v.each do |e|
    s += (s.empty?() ? e.to_s : ' ' + e.to_s)
  end
  return s
end

n = 100
size = 1000

puts "Vector#join (internal/external iteration)"
bm do |x|
  v = GSLng::Vector.zero(size)
  x.report("internal:") {n.times {v.join(' ')}}
  x.report("external:") {n.times {my_join(v)}}
end

n = 500
size = 50000

puts "Norm"
bm do |x|
  v = GSLng::Vector.random(size)
  gv = GSL::Vector.alloc(v.to_a)
  x.report("GSLng  :") {n.times {v.norm}}
  x.report("rb-gsl :") {n.times {gv.dnrm2}}
end

n=5000
size = 5000
puts "Vector product"
bm do |x|
  v,v2 = GSLng::Vector.random(size),GSLng::Vector.random(size)
  gv,gv2 = GSL::Vector.alloc(v.to_a),GSL::Vector.alloc(v2.to_a)
  x.report("rb-gsl :") {n.times {gv.mul!(gv2)}}
  x.report("GSLng  :") {n.times {v.mul(v2)}}
end

n=500
size = 5000
puts "Sort"
bm do |x|
  v = GSLng::Vector.random(size)
  gv = GSL::Vector.alloc(v.to_a)
  x.report("rb-gsl :") {n.times {v.sort!}}
  x.report("GSLng  :") {n.times {gv.sort!}}
end
