# Version numbering: http://wiki.github.com/sandal/prawn/development-roadmap
PRAWN_OVAL_TEXT_VERSION = "0.11.1"

Gem::Specification.new do |spec|
  spec.name = "prawn_oval_text"
  spec.version = PRAWN_OVAL_TEXT_VERSION
  spec.platform = Gem::Platform::RUBY
  spec.summary = "Oval text for Prawn"
  spec.files =  Dir.glob("{examples,lib,spec}/**/**/*") +
                      ["Rakefile", "prawn_oval_text.gemspec"]
  spec.require_path = "lib"
  spec.required_ruby_version = '>= 1.8.7'
  spec.required_rubygems_version = ">= 1.3.6"

  spec.test_files = Dir[ "spec/*_spec.rb" ]
  spec.extra_rdoc_files = %w{README.rdoc LICENSE}
  spec.rdoc_options << '--title' << 'Prawn Oval Text Documentation' <<
                       '--main'  << 'README.rdoc' << '-q'
  spec.authors = ["Daniel Nelson"]
  spec.email = ["dnelson@bluejade.com"]
  spec.add_dependency('prawn', '>=0.11.1')
  spec.homepage = "https://github.com/Bluejade/prawn-oval-text"
  spec.description = <<END_DESC
  Adds oval shaped text to Prawn
END_DESC
end
