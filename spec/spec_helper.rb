# encoding: utf-8
require "rubygems"
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),
                             '..', 'lib')
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),
                             '..', 'vendor', 'prawn-core', 'lib')

require "prawn"
Prawn.debug = true

require "test/spec"
require "mocha"

def create_pdf(klass=Prawn::Document)
  @pdf = klass.new(:left_margin   => 0,
                   :right_margin  => 0,
                   :top_margin    => 0,
                   :bottom_margin => 0)
end    
