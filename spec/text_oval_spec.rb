# encoding: utf-8
require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

require 'prawn/text/oval'

describe "Text::Oval" do
  it "should print text" do
    create_pdf
    options = {
      :width => 162.0,
      :height => 162.0,
      :center => [81.0, 639.0],
      :crop => 0,
      :document => @pdf
    }
    text = "Hello world"
    text_oval = Prawn::Text::Oval.new(text, options)
    text_oval.render
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings[0].should == "Hello"
    text.strings[1].should == "world"
  end
end

describe "Text::Oval with text than can fit in the oval" do
  before(:each) do
    create_pdf
    @text = "Oh hai text oval. " * 10
    @options = {
      :width => 162.0,
      :height => 162.0,
      :center => [81.0, 639.0],
      :crop => 0,
      :document => @pdf
    }
  end

  it "printed text should match requested text, except for trailing or leading white space and that spaces may be replaced by newlines" do
    text_oval = Prawn::Text::Oval.new(@text, @options)
    text_oval.render
    text_oval.text.gsub("\n", " ").should == @text.strip
  end

  it "render should return an empty string because no text remains unprinted" do
    text_oval = Prawn::Text::Oval.new(@text, @options)
    text_oval.render.should == ""
  end

  it "should be truncated when the leading is set high enough to prevent all the lines from being printed" do
    @options[:leading] = 40
    text_oval = Prawn::Text::Oval.new(@text, @options)
    text_oval.render
    text_oval.text.gsub("\n", " ").should.not == @text.strip
  end

  it "printed text should be identical for all three alignments" do
    @options[:align] = :left
    text_oval = Prawn::Text::Oval.new(@text, @options)
    text_oval.render
    left_text = text_oval.text

    @options[:align] = :center
    text_oval = Prawn::Text::Oval.new(@text, @options)
    text_oval.render
    center_text = text_oval.text

    @options[:align] = :right
    text_oval = Prawn::Text::Oval.new(@text, @options)
    text_oval.render
    right_text = text_oval.text

    left_text.should == center_text
    center_text.should == right_text
  end
end

describe "Text::Oval with longer text than can fit in the oval" do
  before(:each) do
    create_pdf
    @text = "Oh hai text oval. " * 15
    @options = {
      :width => 162.0,
      :height => 162.0,
      :center => [81.0, 639.0],
      :crop => 0,
      :document => @pdf
    }
  end

  context "truncated overflow" do
    before(:each) do
      @options[:overflow] = :truncate
      @text_oval = Prawn::Text::Oval.new(@text, @options)
    end
    it "should not display ellipses" do
      @text_oval.render
      @text_oval.text.should.not =~ /\.\.\./
    end
    it "should be truncated" do
      @text_oval.render
      @text_oval.text.gsub("\n", " ").should.not == @text.strip
    end
    it "render should not return an empty string because some text remains unprinted" do
      @text_oval.render.should.not == ""
    end
  end

  context "ellipses overflow" do
    before(:each) do
      @options[:overflow] = :ellipses
      @text_oval = Prawn::Text::Oval.new(@text, @options)
    end
    it "should display ellipses" do
      @text_oval.render
      @text_oval.text.should =~ /\.\.\./
    end
    it "render should not return an empty string because some text remains unprinted" do
      @text_oval = Prawn::Text::Oval.new(@text, @options)
      @text_oval.render.should.not == ""
    end
  end

  context "shrink_to_fit overflow" do
    before(:each) do
      @options[:overflow] = :shrink_to_fit
      @options[:min_font_size] = 2
      @text_oval = Prawn::Text::Oval.new(@text, @options)
    end
    it "should display the entire text" do
      @text_oval.render
      @text_oval.text.gsub("\n", " ").should == @text.strip
    end
    it "render should return an empty string because no text remains unprinted" do
      @text_oval.render.should == ""
    end
  end

  it "printed text should be identical for all three alignments" do
    @options[:align] = :left
    text_oval = Prawn::Text::Oval.new(@text, @options)
    text_oval.render
    left_text = text_oval.text

    @options[:align] = :center
    text_oval = Prawn::Text::Oval.new(@text, @options)
    text_oval.render
    center_text = text_oval.text

    @options[:align] = :right
    text_oval = Prawn::Text::Oval.new(@text, @options)
    text_oval.render
    right_text = text_oval.text

    left_text.should == center_text
    center_text.should == right_text
  end
end

describe "Text::Oval with a single word that is longer than can fit in the oval" do
  before(:each) do
    create_pdf
    @text = "Ohhaitextoval" * 100
    @options = {
      :width => 162.0,
      :height => 162.0,
      :center => [81.0, 639.0],
      :crop => 0,
      :document => @pdf
    }
  end

  context "with a crop greater than zero" do
  it "should print less text than without a crop" do
    @options[:crop] = 0
    text_oval = Prawn::Text::Oval.new(@text, @options)
    text_oval.render
    full_text = text_oval.text

    @options[:crop] = @pdf.font.height
    text_oval = Prawn::Text::Oval.new(@text, @options)
    text_oval.render
    cropped_text = text_oval.text

    cropped_text.length.should < full_text.length
    end
  end
end

describe "Text::Oval with a solid block of Chinese characters" do
  before(:each) do
    create_pdf
    @text = "写中国字" * 10
    @options = {
      :width => 162.0,
      :height => 162.0,
      :center => [81.0, 639.0],
      :crop => 0,
      :document => @pdf
    }
    @pdf.font "#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf"
  end

  it "printed text should match requested text, except for newlines" do
    text_oval = Prawn::Text::Oval.new(@text, @options)
    text_oval.render
    text_oval.text.gsub("\n", "").should == @text.strip
  end
end
