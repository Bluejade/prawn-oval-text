# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

require 'prawn/document/text/oval'

describe "Text::Oval with text than can fit in the oval" do
  before(:each) do
    create_pdf    
    @text = "Oh hai text oval. " * 10
    @options = {
      :align => :left,
      :width => 162.0,
      :height => 162.0,
      :overflow => :ellipses,
      :center => [81.0, 639.0],
      :crop => 0,
      :for  =>  @pdf
    }
  end
  
  it "printed text should match requested text, except for trailing or leading white space and that spaces may be replaced by newlines" do
    @options[:overflow] = :truncate
    oval_text = Prawn::Document::Text::Oval.new(@text, @options)
    oval_text.render
    oval_text.text.gsub("\n", " ").should == @text.strip
  end
  
  it "render should return an empty string because no text remains unprinted" do
    @options[:overflow] = :truncate
    oval_text = Prawn::Document::Text::Oval.new(@text, @options)
    oval_text.render.should == ""
  end

  it "should be truncated when the leading is set high enough to prevent all the lines from being printed" do
    @options[:leading] = 40
    oval_text = Prawn::Document::Text::Oval.new(@text, @options)
    oval_text.render
    oval_text.text.gsub("\n", " ").should_not == @text.strip
  end
  
  it "printed text should be identical for all three alignments" do
    @options[:align] = :left
    oval_text = Prawn::Document::Text::Oval.new(@text, @options)
    oval_text.render
    left_text = oval_text.text
    
    @options[:align] = :center
    oval_text = Prawn::Document::Text::Oval.new(@text, @options)
    oval_text.render
    center_text = oval_text.text
    
    @options[:align] = :right
    oval_text = Prawn::Document::Text::Oval.new(@text, @options)
    oval_text.render
    right_text = oval_text.text

    left_text.should == center_text
    center_text.should == right_text
  end
end

describe "Text::Oval with longer text than can fit in the oval" do
  before(:each) do
    create_pdf    
    @text = "Oh hai text oval. " * 15
    @options = {
      :align => :left,
      :width => 162.0,
      :height => 162.0,
      :overflow => :ellipses,
      :center => [81.0, 639.0],
      :crop => 0,
      :for  =>  @pdf
    }
  end
  
  context "truncated overflow" do
    before(:each) do
      @options[:overflow] = :truncate
      @oval_text = Prawn::Document::Text::Oval.new(@text, @options)
    end
    it "should not display ellipses" do
      @oval_text.render
      @oval_text.text.should_not =~ /\.\.\./
    end
    it "should be truncated" do
      @oval_text.render
      @oval_text.text.gsub("\n", " ").should_not == @text.strip
    end
    it "render should not return an empty string because some text remains unprinted" do
      @oval_text.render.should_not == ""
    end
  end
  
  context "ellipses overflow" do
    before(:each) do
      @options[:overflow] = :ellipses
      @oval_text = Prawn::Document::Text::Oval.new(@text, @options)
    end
    it "should display ellipses" do
      @oval_text.render
      @oval_text.text.should =~ /\.\.\./
    end
    it "render should not return an empty string because some text remains unprinted" do
      @options[:overflow] = :ellipses
      @oval_text = Prawn::Document::Text::Oval.new(@text, @options)
      @oval_text.render.should_not == ""
    end
  end

  context "shrink_to_fit overflow" do
    before(:each) do
      @options[:overflow] = :shrink_to_fit
      @options[:min_font_size] = 2
      @oval_text = Prawn::Document::Text::Oval.new(@text, @options)
    end
    it "should display the entire text" do
      @oval_text.render
      @oval_text.text.gsub("\n", " ").should == @text.strip
    end
    it "render should return an empty string because no text remains unprinted" do
      @oval_text.render.should == ""
    end
  end
  
  it "printed text should be identical for all three alignments" do
    @options[:align] = :left
    oval_text = Prawn::Document::Text::Oval.new(@text, @options)
    oval_text.render
    left_text = oval_text.text
    
    @options[:align] = :center
    oval_text = Prawn::Document::Text::Oval.new(@text, @options)
    oval_text.render
    center_text = oval_text.text
    
    @options[:align] = :right
    oval_text = Prawn::Document::Text::Oval.new(@text, @options)
    oval_text.render
    right_text = oval_text.text

    left_text.should == center_text
    center_text.should == right_text
  end
end

describe "Text::Oval with a single word that is longer than can fit in the oval" do
  before(:each) do
    create_pdf    
    @text = "Ohhaitextoval" * 100
    @options = {
      :align => :left,
      :width => 162.0,
      :height => 162.0,
      :overflow => :ellipses,
      :center => [81.0, 639.0],
      :crop => 0,
      :for  =>  @pdf
    }
  end

  context "with a crop greater than zero" do
  it "should print less text than without a crop" do
    @options[:crop] = 0
    oval_text = Prawn::Document::Text::Oval.new(@text, @options)
    oval_text.render
    full_text = oval_text.text
    
    @options[:crop] = @pdf.font.height
    oval_text = Prawn::Document::Text::Oval.new(@text, @options)
    oval_text.render
    cropped_text = oval_text.text

    cropped_text.length.should < full_text.length
    end
  end
end

describe "Text::Oval with a solid block of Chinese characters" do
  before(:each) do
    create_pdf    
    @text = "写中国字" * 10
    @options = {
      :align => :left,
      :width => 162.0,
      :height => 162.0,
      :overflow => :ellipses,
      :center => [81.0, 639.0],
      :crop => 0,
      :for  =>  @pdf
    }
  end
  
  it "printed text should match requested text, except for newlines" do
    @options[:overflow] = :truncate
    oval_text = Prawn::Document::Text::Oval.new(@text, @options)
    oval_text.render
    oval_text.text.gsub("\n", "").should == @text.strip
  end
end
