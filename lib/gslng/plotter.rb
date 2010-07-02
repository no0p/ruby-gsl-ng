require 'singleton'
require 'ffi'

module GSLng
  # This module encapsulates the communication with the plotting backend: gnuplot.
  class Plotter
    include Singleton

    attr_reader :io

    def initialize
      self.open
    end

    def reopen
      unless (@io.closed?) then raise 'pipe already open' end
      self.open
    end

    def close
      @io.close
    end

    def <<(cmd)
      @io.puts(cmd)
    end

    def open # @private
      @io = IO.popen('gnuplot > /dev/null', 'w')
      self << "set datafile nofpe_trap"
    end
  end

  class Matrix
    def plot_image(extra_cmds = '')
      p = Plotter.instance
      p << "plot '-' binary array=(#{self.m},#{self.n}) format='%double' #{extra_cmds} with image"
      GSLng.backend.gsl_matrix_putdata(self.ptr, p.io.to_i)
    end
  end
end
