# encoding: utf-8
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

prawn_symlink = File.join(File.dirname(__FILE__), '..', 'vendor','prawn')
unless File.symlink?(prawn_symlink)
  puts 'Running specs requires symlinked vendor/prawn directory that points to prawn'
  return
end
prawn_dir = File.readlink(prawn_symlink)
$LOAD_PATH.unshift File.join(prawn_dir, 'lib')

require 'prawn/core'
Prawn.debug = true

def create_pdf(klass=Prawn::Document)
  @pdf = klass.new(:left_margin   => 0,
                   :right_margin  => 0,
                   :top_margin    => 0,
                   :bottom_margin => 0)
end    
