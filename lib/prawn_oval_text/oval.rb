# encoding: utf-8

# prawn_oval_text/oval.rb : Implements text ovals
#
# Copyright October 2009-2011, Daniel Nelson. All Rights Reserved.
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
    def text_oval(text, options={})
      Text::Oval.new(text, options.merge(:document => self)).render
    end

    # Provides oval shaped text capacity
    #
    class Oval < Prawn::Text::Formatted::Oval

      def initialize(string, options={})
        super([{ :text => string }], options)
      end

      def render(flags={})
        leftover = super(flags)
        leftover.collect { |hash| hash[:text] }.join
      end

    end
  end
end
