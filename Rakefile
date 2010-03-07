# -*- ruby -*-
require 'rubygems'
require 'rake'
require 'echoe'
require 'yard'

Echoe.new('ruby-gsl-ng') do |p|
  p.author = 'v01d'
  p.summary = "Ruby Object Oriented Graph LIbrary"
  p.url = "http://github.com/v01d/roogli"
  p.version = "0.2.2"
  p.dependencies = ['yard', 'ffi']
#  p.eval = proc { s.has_rdoc = 'yard' }
end

YARD::Rake::YardocTask.new do |t|
  t.options = ['--verbose','--no-private']
end

