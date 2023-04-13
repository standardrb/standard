source "https://rubygems.org"

gemspec

gem "bundler"
gem "minitest", "~> 5.0"
gem "rake", "~> 13.0"
gem "gimme"
gem "m"

gem "lint_roller", path: "../lint_roller"
gem "standard-custom", path: "../standard-custom"
gem "standard-performance", path: "../standard-performance"

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.5")
  gem "simplecov"
end
