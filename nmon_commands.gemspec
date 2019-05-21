
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nmon_commands/version"

Gem::Specification.new do |spec|
  spec.name          = "nmon_commands"
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

  spec.add_dependency "optimist", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "awesome_print"
end
