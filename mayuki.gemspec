require File.expand_path('../lib/mayuki/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "mayuki"
  s.version     = Mayuki::VERSION
  s.date        = Mayuki::DATE
  s.summary     = "Markdown/YAML-based static wiki generator."
  s.description = "Mayuki is a minimalist Markdown/YAML-based static wiki generator."
  s.license     = "MIT"
  
  s.homepage    = "http://www.soimort.org/mayuki/"
  s.has_rdoc    = false
  
  s.authors     = ["Mort Yao"]
  s.email       = "mort.yao@gmail.com"
  
  s.add_runtime_dependency("liquid", "~> 2.3")
  s.add_runtime_dependency("rdiscount", "~> 2.0")
  s.add_development_dependency("rake", ">= 0.9")
  s.requirements = ["Pygments >= 1.5", "Git >= 1.7"]
  
  s.executables = ["mayuki"]
  
  # = MANIFEST =
  s.files       = %w[
    bin/mayuki
    lib/mayuki.rb
    lib/mayuki/liquid_filter.rb
    lib/mayuki/version.rb
  ]
  # = MANIFEST =
end
