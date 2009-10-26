# encoding: utf-8
#
# A text oval is positioned by its center or by its top-left corner,
# its width, and its height. It forms an invisible container within
# which to flow text. If more text is provided than can fit, it will
# be either truncated or post-fixed with ellipses.

require 'examples/example_helper'
require 'prawn/document/text/oval'

Prawn::Document.generate("oval_text.pdf") do

  stroke_color("555555")
  bounds_h_middle = (bounds.left + bounds.right) * 0.5
  bounds_v_middle = (bounds.bottom + bounds.top) * 0.5
  diameter = bounds.width * 0.3
  base_options = {
                  :width    => diameter,
                  :height   => diameter,
                  :overflow => :ellipses,
                  :crop     => 0,
                  :center   => [0, 0],
                  :align    => :left,
                 }
  3.times do |i|
    4.times do |j|
      options = base_options.clone
      center = options[:center]
      
      case i
      when 0
        text = "this is left text " * 25
        center[0] = options[:width] * 0.5
      when 1
        text = "this is center text " * 25
        center[0] = bounds_h_middle
        options[:align] = :center
      when 2
        text = "this is right text " * 25
        center[0] = bounds.right - options[:width] * 0.5
        options[:align] = :right
      end
      
      case j
      when 0
        text = text.split(" ").slice(0..48).join(" ")
      when 1
        options[:crop] = font.height
      when 2
        options[:crop] = font.height
        options[:leading] = font.height * 0.5
        options[:overflow] = :truncate
      when 3
        text.delete!(" ")
      end
      
      center[0] = bounds.left + options[:width] * 0.5 + (bounds.width  - options[:width]) * 0.5 * i
      center[1] = bounds.top - options[:height] * 0.5 - (bounds.height - options[:height]) * 0.33 * j
      
      stroke_circle_at(center, :radius => (options[:width] * 0.5))
      #puts text
      #p options
      #puts ''
      oval_text(text, options)
    end
  end
end