$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))


prawn_symlink = File.join(File.dirname(__FILE__), '..', 'vendor','prawn')
unless File.symlink?(prawn_symlink)
  puts 'Running specs requires symlinked vendor/prawn directory that points to prawn'
  return
end
prawn_dir = File.readlink(prawn_symlink)
$LOAD_PATH.unshift File.join(prawn_dir, 'lib')

require 'prawn/core'
Prawn.debug = true
