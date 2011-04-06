# encoding: utf-8

# prawn_oval_text/formatted/oval.rb : Implements text ovals
#
# Copyright October 2009-2011, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  module Text
    module Formatted

      # Draws the requested formatted text into an oval.
      #
      # == Example
      #
      #   formatted_text_oval([{ :text => "hello" },
      #                        { :text => "world",
      #                          :direction => :rtl,
      #                          :styles => [:bold, :italic],
      #                          :color => "0000ff" }])
      #
      # == Options
      #
      # Accepts the same options as #text_oval, and the formatted text array is
      # the same as for #formatted_text_box, with one warning: The baseline_y
      # within the oval determines how much width is available to that
      # line. Whereas, with text boxes, text fragments are free to change height
      # within a line (via the size or font options), for line width
      # calculations in oval text, we use the font settings in place at the time
      # the text is drawn to the oval. So, changing font to a much larger font or
      # increasing font size within a text fragment will not produce good results.
      #
      def formatted_text_oval(array, options={})
        Text::Formatted::Oval.new(array, options.merge(:document => self)).render
      end

      # Provides oval shaped text capacity
      #
      class Oval < Prawn::Text::Formatted::Box

        DEFAULT_CROP_INCREMENT = 5

        def valid_options
          super.concat([:crop, :center])
        end
        
        def initialize(formatted_text, options={})

          super(formatted_text, options)

          @horizontal_radius = options[:width] * 0.5
          @vertical_radius   = options[:height] * 0.5
          @height            = options[:height]
          @center            = [@at[0] + @horizontal_radius,
                                @at[1] - @vertical_radius]
          @center            = options[:center] if options[:center]
          @at                = [@center[0] - @horizontal_radius,
                                @center[1] + @vertical_radius]
          @original_x        = @at[0]
          @align             = options[:align] || :center
          @vertical_align    = :top

          # the crop lets us start printing text some distance below the
          # top of the ellipse, otherwise, there may not be enough space
          # to display much text, which looks bad
          crop = [options[:crop] || 0, @document.font.descender].max
          increase_crop(crop)
        end

        # def height
        #   @vertical_radius * 2
        # end

        def available_width
          @width = compute_max_line_width(@horizontal_radius, @vertical_radius, width_limiting_y)
          @at[0] = @original_x + @horizontal_radius - @width * 0.5
          [@width, @line_height].max
        end

        def render(flags={})
          @oval_line_height = @document.font.height
          @oval_descender   = @document.font.descender
          @oval_ascender    = @document.font.ascender
          @oval_line_gap    = @document.font.line_gap
          #          begin
          #            results = super(flags)
          super(flags)
          # rescue Prawn::Errors::CannotFit
          #   if @baseline_y.abs < @height - @oval_line_height
          #     increase_crop
          #     retry
          #   end
          #   results = []
          # end
          # results
        end
        
        private

        # Override because oval text is more succeptable to change in the lower
        # part of the circle (due to ever diminishing space), so we want a
        # finer-grained font reduction
        #
        def shrink_to_fit(text)
          wrap(text)
          until @everything_printed || @font_size <= @min_font_size
            @font_size = [@font_size - 0.3, @min_font_size].max
            @document.font_size = @font_size
            wrap(text)
          end
        end

        # Override because the #word_spacing_for_this_line in
        # Prawn::Core::Text::Formatted::Wrap recomputes available_width, even
        # though it has already moved on to the next line
        #
        def word_spacing_for_this_line
          if @align == :justify &&
              @line_wrap.space_count > 0 &&
              !@line_wrap.paragraph_finished?
            (@width - @line_wrap.width) / @line_wrap.space_count
          else
            0
          end
        end

        def increase_crop(amount=DEFAULT_CROP_INCREMENT)
          @crop ||= 0
          @crop   += amount
          @at[1]  -= amount
          @height -= amount + 1
        end

        def oval_baseline_y
          if @baseline_y == 0
            -@crop - @oval_ascender
          else
            @baseline_y - @crop - (@oval_line_height + @leading)
          end
        end

        # Width_limiting_y is the value of y that will be used to compute x;
        # whereas, y is the vertical position of the text baseline
        def width_limiting_y
          return (oval_baseline_y + @vertical_radius + @oval_ascender) if above_x_axis?
          (oval_baseline_y + @vertical_radius - @oval_descender)
        end

        # When we are above the x-axis, the top of the ascender is
        # limited by the ellipse. When below the y-axis, the bottom
        # of the descender is limited by the ellipse
        def above_x_axis?
          (oval_baseline_y + @vertical_radius).abs > (oval_baseline_y + @vertical_radius - @oval_line_height).abs
        end
        
        def compute_max_line_width(a, b, y)
          # equation of ellipse is x^2 / a^2 + y^2 / b^2 = 1, which
          # reduces to the following line
          b_squared = b * b
          y_squared = [y * y, b_squared].min
          x = a * Math.sqrt(1 - y_squared / b_squared)
          2 * x
        end
      end
    end
  end
end
