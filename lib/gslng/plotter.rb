require 'gslng/plotter_backend'

module GSLng
  # This module encapsulates the communication with the plotting backend: PLplot.
  module Plotter
    def self.init
      backend.plsdev('xwin')
      backend.plinit
    end

    def self.end
      backend.plend
    end
  end
end
