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
    @text = "Oh hai text oval. " * 100
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
    it "should not display ellipses" do
      @options[:overflow] = :truncate
      oval_text = Prawn::Document::Text::Oval.new(@text, @options)
      oval_text.render
      oval_text.text.should_not =~ /\.\.\./
    end
    it "should be truncated" do
      @options[:overflow] = :truncate
      oval_text = Prawn::Document::Text::Oval.new(@text, @options)
      oval_text.render
      oval_text.text.gsub("\n", " ").should_not == @text.strip
    end
  end
  
  context "ellipses overflow" do
    it "should display ellipses" do
      oval_text = Prawn::Document::Text::Oval.new(@text, @options)
      oval_text.render
      oval_text.text.should =~ /\.\.\./
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
