# frozen_string_literal: true

Gem::Specification.new do |gem|
  gem.name = "test-cmd.rb"
  gem.authors = ["0x1eef"]
  gem.email = ["0x1eef@protonmail.com"]
  gem.homepage = "https://github.com/0x1eef/test-cmd.rb#readme"
  gem.version = "0.7.0"
  gem.required_ruby_version = ">= 3.0"
  gem.licenses = ["0BSD"]
  gem.files = `git ls-files`.split($/)
  gem.require_paths = ["lib"]
  gem.summary = "An object-oriented interface for spawning a process."
  gem.metadata = { "documentation_uri" => "https://0x1eef.github.io/x/test-cmd.rb/" }
  gem.description = gem.summary
  gem.add_development_dependency "test-unit", "~> 3.5.7"
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "redcarpet", "~> 3.5"
  gem.add_development_dependency "standard", "~> 1.24"
  gem.add_development_dependency "rake", "~> 13.1"
end
