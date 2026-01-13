require_relative "lib/standard/version"

Gem::Specification.new do |spec|
  spec.name = "standard"
  spec.version = Standard::VERSION
  spec.authors = ["Justin Searls"]
  spec.email = ["searls@gmail.com"]
  spec.required_ruby_version = ">= 3.0.0"

  spec.summary = "Ruby Style Guide, with linter & automatic code fixer"
  spec.homepage = "https://github.com/standardrb/standard"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.add_dependency "rubocop", "~> 1.82.0"

  spec.add_dependency "lint_roller", "~> 1.0"
  spec.add_dependency "standard-custom", "~> 1.0.0"
  spec.add_dependency "standard-performance", "~> 1.8"

  # not semver: first three are lsp protocol version, last is patch
  spec.add_dependency "language_server-protocol", "~> 3.17.0.2"
end
