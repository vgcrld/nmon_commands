
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nmon_commands/setup"

Gem::Specification.new do |spec|
  spec.name          = "nmon_commands"
  spec.license       = "MIT"
  spec.version       = NmonCommands::VERSION
  spec.authors       = ["Rich Davis"]
  spec.email         = ["rdavis@galileosuite.com"]

  spec.summary       = "Get NMON Commands"
  spec.description   = "A simple gem to read and expost NMON command data from a phase1 file."
  spec.homepage      = "https://www.galileosuite.com"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "haml", "~> 5.1"
  spec.add_dependency "sinatra", "~> 2.0"
  spec.add_dependency "sinatra-cross_origin", "~> 0.4"
  spec.add_dependency "optimist", "~> 3"
  spec.add_dependency 'date', '~> 0.0.1'

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "awesome_print", "~> 1.8"
end
