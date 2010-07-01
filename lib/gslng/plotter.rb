require 'gslng/plotter_backend'

module GSLng
  # This module encapsulates the communication with the plotting backend: PLplot.
  module Plotter
    DEFAULT_DRIVER='xwin'

    def self.init(x_pages = 1, y_pages = 1, driver = DEFAULT_DRIVER)
      backend.plstart(driver, x_pages, y_pages)
    end

    def self.end
      backend.plend
    end

    def self.flush
      backend.plflush
    end

    # This method yields the block, taking care of calling {#init} and {#end}
    def self.plot(*args)
      self.init(*args)
      yield
    ensure
      self.end
    end

    def self.persist=(v)
      backend.plspause(v)
    end

    def self.grayscale
      backend.plplot_set_grayscale
    end

    def self.background_color=(rgb)
      colors = rgb.map {|c| (c * 255).to_i}
      puts colors
      backend.plscolbg(*colors)
    end

    # Start a new plot, given the axis ranges:
    # @param xmin [Float] Minimum value for the X axis
    # @param xmax [Float] Maximum value for the X axis
    # @param ymin [Float] Minimum value for the Y axis
    # @param ymax [Float] Maximum value for the Y axis
    def self.new_plot(xmin = 0, xmax = 1, ymin = 0, ymax = 1)
      backend.plenv(xmin, xmax, ymin, ymax, 1, -2)
    end
  end

  class Matrix
    class PlotData
      attr_reader :ptr

      def initialize(matrix)
        ptr = Plotter.backend.plplot_alloc_plplotgrid(matrix.ptr)
        @ptr = FFI::AutoPointer.new(ptr, PlotData.get_releaser(matrix.n))
        @matrix = matrix
      end

      def PlotData.get_releaser(n)
        lambda {|ptr| Plotter.backend.plplot_free_plplotgrid(ptr, n) }
      end
    end

    def plot_image(zmin = 0, zmax = 1, xmin = 0, xmax = 1, ymin = 0, ymax = 1)
      Plotter.backend.plimagefr(PlotData.new(self).ptr, self.n, self.m, xmin, xmax, ymin, ymax, zmin, zmax, xmin, xmax, nil, nil)
    end
  end
end
