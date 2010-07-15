require 'singleton'
require 'ffi'

module GSLng
  # This class encapsulates the communication with the plotting backend: gnuplot.
  #
  # Plot data is always represented as a {Matrix}, so you can use {Matrix#plot} to do a single plot.
  # Otherwise, you can use {Matrix#define_plot} (taking the same parameters as the previous method) which returns a {Plotter::Plot}
  # object. By defining multiple plot objects you can then use {Plotter#plot} passing all plot objects as parameters effectively
  # creating a single output of all plots.
  #
  # This class works as {Singleton}, so when you instantiate it the gnuplot process is started. You can also send arbitrary commands
  # to the gnuplot process by using the {Plotter#<<} operator. Read the gnuplot documentation on what are the possible commands you can send.
  # 
  class Plotter
    include Singleton

    attr_reader :io

    # Creates the singleton Plotter object
    def initialize
      @io = IO.popen('gnuplot -', 'w')
      self << "set datafile nofpe_trap"
    end

    # Send a command to the gnuplot process
    # @example Setting the xrange
    #  Plotter.instance << "set xrange [0:1]"
    def <<(cmd)
      @io.puts(cmd)
    end

    # Expects a variable number of {Plot} objects and creates a single plot out of them
    def plot(*plots)
      self << 'plot ' + plots.map(&:command).join(', ')
      plots.each {|p| self.put_data(p.matrix)}
    end

    def put_data(matrix) # @private
      ret = GSLng.backend.gsl_matrix_putdata(matrix.ptr, @io.to_i)
      if (ret != 0) then raise SystemCallError.new("Problem sending data to gnuplot", ret) end
    end

    # Yields the given block enabling and disabling multiplot mode, before and after the yield respectively
    def multiplot
      self << 'set multiplot'
      yield(self)
    ensure
      self << 'unset multiplot'
    end

    # This class holds a "plot" command and the associated matrix
    class Plot < Struct.new(:command, :matrix); end
  end

  class Matrix
    # Create a single plot out of the data contained in this Matrix
    # @param [String] with The value of the 'with' option in gnuplot's plot command (i.e.: lines, linespoints, image, etc.)
    # @param [String] extra_cmds Other variables/modifiers you can optionally pass to the "plot" command
    def plot(with, extra_cmds = '')
      Plotter.instance.plot(define_plot(with, extra_cmds))
    end

    # Works the same as {#plot} but returns a {Plotter::Plot} object you can store and then pass (along with other plot objects)
    # to {Plotter#plot} and create a single plot out of them
    # @return [Plot] The plot object you can pass to {Plotter#plot}
    def define_plot(with, extra_cmds = '')
      if (with == 'image')
        cmd = "'-' binary array=(#{self.m},#{self.n}) format='%double' #{extra_cmds} with #{with}"
      else
        cmd = "'-' binary record=(#{self.m}) format=\"#{Array.new(self.n,'%double').join('')}\" #{extra_cmds} with #{with}"
      end
      Plotter::Plot.new(cmd, self)
    end
  end
end
