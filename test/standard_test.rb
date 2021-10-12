require "test_helper"

class StandardTest < UnitTest
  def test_loads_stuff
    refute_nil RuboCop
    refute_nil Standard::Cli
    refute_nil RuboCop::Cop::Standard::BlockSingleLineBraces
    assert_instance_of Gem::Version, ::Standard::VERSION
  end

  def test_configured_all_cops
    base = "config/base.yml"

    # see if everything is configured
    allowed = Standard::BuildsConfig.new.call([]).
      rubocop_config_store.
      instance_variable_get(:@options_config).
      instance_variable_get(:@hash).
      keys
    configured = YAML.load_file(base).keys
    missing = (allowed - configured).grep(/\//) # ignore groups like "Layout"
    extra = (configured - allowed).grep(/\AA-Z/) # ignore "require"
    return if missing == [] && extra == []

    if missing.any? && !ENV["CI"]
      # rewrite file to add missing sections
      separator = "\n\n"
      sections = File.read(base).strip.split(separator)
      sections += missing.map { |key| "#{key}:\n  Enabled: false" }
      sections = sections.first(1) + sections[1..-1].sort # keep require in the front
      File.write(base, sections.join(separator) + "\n")
      flunk "#{base} has been rewritten to add missing cops, review and commit it"
    end

    assert_equal missing, [], "Configure these cops as either Enabled: true or Enabled: false in #{base}"
    assert_equal extra, [], "These cops do not exist and should not be configured in #{base}"
  end
end
