require "rubygems"
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'vendor', 'prawn', 'lib'))
require 'prawn'

Prawn.debug = true
