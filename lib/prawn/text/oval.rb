# encoding: utf-8

# text/oval.rb : Implements text ovals
#
# Copyright October 2009, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
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
    #     :kerning is a boolean. Defaults to true. Note that if
    #       kerning is on, it will result in slower width
    #       computations
    #   
    #     :align is :center, :left, :right, or :justify. Defaults to :center
    #
    #     :min_font_size is the minimum font-size to use when
    #       :overflow is set to :shrink_to_fit (ie: the font size
    #       will not be reduced to less than this value, even if it
    #       means that some text will be cut off). Defaults to 5

    # +text+ must be UTF8-encoded.
    #
    def text_oval(text, options)
      Text::Oval.new(text, options.merge(:document => self)).render
    end

    # Provides oval shaped text capacity
    #
    class Oval < Prawn::Text::Box #:nodoc:
      # version corresponds to the version of Prawn to which this was developed
      VERSION = '0.10.2'

      def valid_options
        super.concat([:crop, :center])
      end
      
      def initialize(text, options={})
        super
        @horizontal_radius = options[:width] * 0.5
        @vertical_radius   = options[:height] * 0.5
        @crop              = options[:crop] || 0
        @center            = [@at[0] + @horizontal_radius,
                              @at[1] - @vertical_radius]
        @center            = options[:center] if options[:center]
        @at                = [@center[0] - @horizontal_radius,
                              @center[1] + @vertical_radius]
        @original_x = @at[0]
        @align             = options[:align] || :center
        @vertical_align    = :top
      end

      def height
        @horizontal_radius * 2
      end

      def wrap(text)
        @text = nil
        remaining_text = text
        @line_height = @document.font.height
        @descender   = @document.font.descender
        @ascender    = @document.font.ascender

        # the crop lets us start printing text some distance below the
        # top of the ellipse, otherwise, there may not be enough space
        # to display much text, which looks bad
        @baseline_y = -@crop - @line_height + @descender
        
        printed_text = []

        while remaining_text &&
              remaining_text.length > 0 &&
              width_limiting_y > -@vertical_radius
          @width = compute_max_line_width(@horizontal_radius, @vertical_radius,
                                          width_limiting_y)
          @at[0] = @original_x + @horizontal_radius - @width * 0.5
          line_to_print = @line_wrap.wrap_line(remaining_text.first_line,
                                               :document => @document,
                                               :kerning => @kerning,
                                               :width => @width)

          remaining_text = remaining_text.slice(@line_wrap.consumed_char_count..
                                                remaining_text.length)
          include_ellipses = (@overflow == :ellipses && last_line? &&
                            remaining_text.length > 0)
          printed_text << draw_line(line_to_print, @line_wrap.width, word_spacing_for_this_line,
                                    include_ellipses)
          @baseline_y -= (@line_height + @leading)
        end

        @text = printed_text.join("\n") if @inked
          
        remaining_text
      end

      def draw_line(line_to_print, line_width=0, word_spacing=0, include_ellipses=false) #:nodoc:
        insert_ellipses(line_to_print) if include_ellipses

        case(@align)
        when :left
          x = @at[0]
        when :center, :justify
          line_width = @width if @align == :justify && word_spacing > 0
          x = @at[0] + @width * 0.5 - line_width * 0.5
        when :right
          x = @at[0] + @width - line_width
        end

        y = @at[1] + @baseline_y

        if @inked
          @document.word_spacing(word_spacing) {
            # remove the || 0 when tying to 0.11+
            @document.character_spacing(@character_spacing || 0) {
              @document.draw_text!(line_to_print, :at => [x, y],
                                   :kerning => @kerning)
            }
          }
        end

        line_to_print
      end
      
      private

      # Width_limiting_y is the value of y that will be used to compute x;
      # whereas, y is the vertical position of the text baseline
      def width_limiting_y
        return (@baseline_y + @vertical_radius + @ascender) if above_x_axis?
        (@baseline_y + @vertical_radius - @descender)
      end

      # When we are above the x-axis, the top of the ascender is
      # limited by the ellipse. When below the y-axis, the bottom
      # of the descender is limited by the ellipse
      def above_x_axis?
        (@baseline_y + @vertical_radius).abs > (@baseline_y + @vertical_radius - @line_height).abs
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
    end
  end
end
