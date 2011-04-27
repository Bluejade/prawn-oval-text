# encoding: utf-8
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Document.generate("text_oval.pdf") do
  def get_string(i, j)      
    case i
    when 0
      # gqpy to show descender relative to outer circle
      text = "this is left gqpy " * 20
    when 1
      if j == 2
        text = "this is justify gqpy " * 7
      else
        text = "this is center gqpy " * 20
      end
    when 2
      text = "this is right gqpy " * 20
    end
    
    case j
    when 0
      text.split(" ").slice(0..47).join(" ")
    when 3
      text.delete(" ").insert(51, "\n\n")
    else
      text
    end
  end

  def get_options(i, j)
    options = {
      :width    => bounds.width * 0.3,
      :height   => bounds.width * 0.3,
      :overflow => :ellipses,
      :center   => [0, 0],
      :align    => :left,
      :document => self
    }
    
    case i
    when 0
      options[:valign] = :top if j == 0
    when 1
      options[:align] = :center
      options[:valign] = :center if j == 0
      options[:align] = :justify if j == 2
    when 2
      options[:align] = :right
      options[:valign] = :bottom if j == 0
    end
    
    case j
    when 1
      options[:overflow] = :shrink_to_fit
    when 2
      options[:leading] = font.height * 0.5
      options[:overflow] = :truncate
    end
    options
  end

  stroke_color("555555")
  3.times do |i|
    4.times do |j|
      options = get_options(i, j)
      options[:center][0] = bounds.left + options[:width] * 0.5 + (bounds.width  - options[:width]) * 0.5 * i
      options[:center][1] = bounds.top - options[:height] * 0.5 - (bounds.height - options[:height]) * 0.33 * j
      oval = Prawn::Text::Oval.new(get_string(i, j), options)
      stroke_circle(options[:center], options[:width] / 2)
      oval.render
    end
  end
end
