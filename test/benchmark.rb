#!/usr/bin/ruby -I../lib -I../ext
require 'benchmark'
require 'gslng'
require 'rbgsl'
require 'narray'
include Benchmark

n = 100
size = 5000

puts "This is GSLng #{GSLng::VERSION}"; puts

puts "Vector#each vs Vector#fast_each - vector of #{size} elements"
bm do |x|
  v = GSLng::Vector.zero(size)
  x.report("each      :") {n.times {s = 0; v.each do |e| s += e end}}
  x.report("fast_each :") {n.times {s = 0; v.fast_each do |e| s += e end}}
end
puts

n = 500
size = 50000

puts "Norm (BLAS) - vector of #{size} elements"
bm do |x|
  v = GSLng::Vector.random(size)
  gv = GSL::Vector.alloc(v.to_a)
  x.report("rb-gsl :") {n.times {gv.dnrm2}}
  x.report("GSLng  :") {n.times {v.norm}}
end
puts

n=5000
size = 5000
puts "Vector product - two vectors of #{size} elements"
bm do |x|
  v,v2 = GSLng::Vector.random(size),GSLng::Vector.random(size)
  gv,gv2 = GSL::Vector.alloc(v.to_a),GSL::Vector.alloc(v2.to_a)
  x.report("rb-gsl :") {n.times {gv.mul!(gv2)}}
  x.report("GSLng  :") {n.times {v.mul!(v2)}}
end
puts

n=500
size = 5000
puts "Sort - vector of #{size} elements"
bm do |x|
  v = GSLng::Vector.random(size)
  gv = GSL::Vector.alloc(v.to_a)
  x.report("rb-gsl :") {n.times {v.sort!}}
  x.report("GSLng  :") {n.times {gv.sort!}}
end
puts
