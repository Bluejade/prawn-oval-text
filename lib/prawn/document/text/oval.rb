# encoding: utf-8

# text/oval.rb : Implements text ovals
#
# Copyright October 2009, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  class Document
    module Text
      # Draws the requested text into an oval. When the text overflows
      # the oval, you can display ellipses, shrink to fit, or
      # truncate the text
      #   acceptable options:
      #
      #     :width and :height are the width and height of the
      #       ellipse, respectively. If they are equal, then the shape
      #       is a circle.
      #
      #     :at is a two element array denoting the upper left corner
      #       of the bounding box around the ellipse
      #
      #     :center is a two element array denoting the center of the
      #       ellipse. If :center is present, then its value overrides
      #       that provided by :at
      #
      #     :overflow is :truncate, :shrink_to_fit, or :ellipses, denoting the
      #       behavior when the amount of text exceeds the available
      #       space. Defaults to :truncate.
      #
      #     :crop denotes the space between top of the oval and the
      #       first line. It is used to push the starting line lower in
      #       the circle when the combination of oval size and font size
      #       result in only a few characters being displayable on the
      #       very top line.
      #
      #     :leading is the amount of space between lines. Defaults to 0
      #
      #     :kerning is a boolean. Defaults to false. Note that a
      #       value of true will result in slower width computations
      #   
      #     :align is :center, :left, or :right. Defaults to :center
      #
      #     :min_font_size is the minimum font-size to use when
      #       :overflow is set to :shrink_to_fit (ie: the font size
      #       will not be reduced to less than this value, even if it
      #       means that some text will be cut off). Defaults to 5

      # +text+ must be UTF8-encoded.
      #
      def oval_text(text, options)
        Text::Oval.new(text, options.merge(:for => self)).render
      end

      # Provides oval shaped text capacity
      #
      class Oval #:nodoc:
        VERSION = '0.3'
        def initialize(text,options={})
          Prawn.verify_options([:for, :width, :height, :crop, :at, :center,
                                :overflow, :leading, :kerning, :align, :min_font_size], options)
          @text              = nil
          @text_to_print     = text.strip
          @document          = options[:for]
          @horizontal_radius = options[:width] * 0.5
          @vertical_radius   = options[:height] * 0.5
          @crop              = options[:crop] || 0
          @center            = [options[:at][0] + @horizontal_radius, options[:at][1] - @vertical_radius] if options[:at]
          @center            = options[:center] if options[:center]
          @overflow          = options[:overflow] || :truncate
          @leading           = options[:leading] || 0
          @kerning           = options[:kerning] || false
          @align             = options[:align] || :center
          @min_font_size     = options[:min_font_size] || 5
        end

        attr_reader :text

        def render
          return _render(@text_to_print) unless @overflow == :shrink_to_fit

          # Decrease the font size until the text fits or the min font
          # size is reached
          original_font_size = @document.font_size
          @document.font_size -= 0.5 while (unprinted_text = _render(@text_to_print, false)).length > 0 &&
                                         @document.font_size > @min_font_size
          _render(@text_to_print)
          @document.font_size = original_font_size
          unprinted_text
        end

        private

        def _render(text_to_print, do_the_print=true)
          @line_height = @document.font.height
          @ascender = @document.font.ascender
          # font.descender returns a negative value, which confuses
          # things later on, so get its absolute value
          @descender = @document.font.descender.abs
          
          # we store the text printed on each line in an array, then
          # join the array with newlines, thereby representing the
          # simulated effect of what was actually printed
          printed_text = []
          
          # baseline_y starts one line height below the top of the
          # circle, which is the vertical_radius. the crop lets us
          # start printing text some distance below the top of the
          # ellipse, otherwise, there may not be enough space to
          # display much text, which looks bad
          @baseline_y = @vertical_radius - @crop - @line_height + @descender

          # while there is text remaining to display, and the bottom
          # of the next line does not extend below the bottom of the ellipse
          while text_to_print && text_to_print.length > 0 && width_limiting_y > -@vertical_radius
            # print a single line, bounded on the left and the right
            # by the ellipse.
            max_line_width = compute_max_line_width(@horizontal_radius, @vertical_radius, width_limiting_y)
            line_to_print = text_that_will_fit_on_current_line(text_to_print, max_line_width)

            # update the remaining text to print to that which was not
            # yet printed.
            text_to_print = text_to_print.slice(line_to_print.length..text_to_print.length)

            # Print the line (strip first to avoid interfering with alignment)
            # Record the text that was actually printed
            printed_text << print_line(line_to_print.strip, max_line_width, @baseline_y, do_the_print)

            # move to the next line
            @baseline_y -= (@line_height + @leading)
          end

          remaining_text = text_to_print
          @text = printed_text.join("\n") if do_the_print
          remaining_text
        end
          
        # Width_limiting_y is the value of y that will be used to compute x;
        # whereas, y is the vertical position of the text baseline
        def width_limiting_y
          return (@baseline_y + @ascender) if above_x_axis?
          (@baseline_y - @descender)
        end

        # When we are above the x-axis, the top of the ascender is
        # limited by the ellipse. When below the y-axis, the bottom
        # of the descender is limited by the ellipse
        def above_x_axis?
          @baseline_y.abs > (@baseline_y - @line_height).abs
        end
          
        # When overflow is set to ellipses, we only want to print
        # ellipses at the end of the last line, so we need to know
        # whether this is the last line
        def last_line?
          width_limiting_y < -@vertical_radius + @line_height
        end
        
        def compute_max_line_width(a, b, y)
          # equation of ellipse is x^2 / a^2 + y^2 / b^2 = 1, which
          # reduces to the following line
          x = a * Math.sqrt(1 - y * y / (b * b))
          2 * x
        end

        def print_line(line_to_print, max_line_width, baseline_y, do_the_print)
          # strip so that trailing white space doesn't interfere with alignment
          line_to_print.rstrip!
          
          if last_line? && @overflow == :ellipses
            if @document.width_of(line_to_print + "...", :kerning => @kerning) < max_line_width
              line_to_print.insert(-1, "...")
            else
              line_to_print[-3..-1] = "..." if line_to_print.length > 3
            end
          end

          case(@align)
          when :left
            x = @center[0] - max_line_width * 0.5
          when :center
            line_width = @document.width_of(line_to_print, :kerning => @kerning)
            x = @center[0] - line_width * 0.5
          when :right
            line_width = @document.width_of(line_to_print, :kerning => @kerning)
            x = @center[0] + max_line_width * 0.5 - line_width
          end
          
          y = baseline_y + @center[1]

          @document.text(line_to_print, :at => [x, y], :kerning => @kerning) if do_the_print
          
          line_to_print
        end
        
        def text_that_will_fit_on_current_line(string, max_line_width)
          scan_pattern = /\S+|\s+/
          
          output = ""

          string.each_line do |line|
            accumulated_width = 0
            line.scan(scan_pattern).each do |segment|
              segment_width = @document.width_of(segment, :size => @document.font_size, :kerning => @kerning)
        
              if accumulated_width + segment_width <= max_line_width
                accumulated_width += segment_width
                output << segment
              else
                # if the line contains white space, don't split the
                # final word that doesn't fit, just return what fits nicely
                return output if output =~ /\s/
                
                # if there is no white space, then just print
                # whatever part of the last segment that will fit on the line
                segment.unpack("U*").each do |char_int|
                  char = [char_int].pack("U")
                  accumulated_width += @document.width_of(char, :size => @document.font_size, :kerning => @kerning)
                  
                  return output if accumulated_width >= max_line_width
                  output << char
                end
              end
            end
            return output
          end

          output
        end
      end
    end
  end
end
