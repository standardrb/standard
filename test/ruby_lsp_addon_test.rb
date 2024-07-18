require "ruby_lsp/internal"
require "ruby_lsp/standard/addon"

require_relative "test_helper"

class RubyLspAddonTest < UnitTest
  def setup
    @addon = RubyLsp::Standard::Addon.new
    super
  end

  def test_name
    assert_equal "Standard Ruby", @addon.name
  end

  def test_diagnostic
    source = <<~RUBY
      s = 'hello'
      puts s
    RUBY
    do_with_fake_io do
      with_server(source, "simple.rb") do |server, uri|
        server.process_message(
          id: 2,
          method: "textDocument/diagnostic",
          params: {
            textDocument: {
              uri: uri
            }
          }
        )

        result = server.pop_response

        assert_instance_of(RubyLsp::Result, result)
        assert_equal "full", result.response.kind
        assert_equal 1, result.response.items.size
        item = result.response.items.first
        assert_equal({line: 0, character: 4}, item.range.start.to_hash)
        assert_equal({line: 0, character: 11}, item.range.end.to_hash)
        assert_equal RubyLsp::Constant::DiagnosticSeverity::INFORMATION, item.severity
        assert_equal "Style/StringLiterals", item.code
        assert_equal "https://docs.rubocop.org/rubocop/cops_style.html#stylestringliterals", item.code_description.href
        assert_equal "Standard Ruby", item.source
        assert_equal "Style/StringLiterals: Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.", item.message
      end
    end
  end

  def test_format
    source = <<~RUBY
      s = 'hello'
      puts s
    RUBY
    do_with_fake_io do
      with_server(source, "simple.rb") do |server, uri|
        server.process_message(
          id: 2,
          method: "textDocument/formatting",
          params: {textDocument: {uri: uri}, position: {line: 0, character: 0}}
        )

        result = server.pop_response

        assert_instance_of(RubyLsp::Result, result)
        assert 1, result.response.size
        assert_equal <<~RUBY, result.response.first.new_text
          s = "hello"
          puts s
        RUBY
      end
    end
  end

  private

  # Lifted from here, because we need to override the formatter to "standard" in the test helper:
  # https://github.com/Shopify/ruby-lsp/blob/4c1906172add4d5c39c35d3396aa29c768bfb898/lib/ruby_lsp/test_helper.rb#L20
  def with_server(source = nil, path = "fake.rb", pwd: "test/fixture/ruby_lsp", stub_no_typechecker: false, load_addons: true,
    &block)
    Dir.chdir pwd do
      server = RubyLsp::Server.new(test_mode: true)
      uri = Kernel.URI(File.join(server.global_state.workspace_path, path))
      server.global_state.formatter = "standard"
      server.global_state.instance_variable_set(:@linters, ["standard"])
      server.global_state.stubs(:typechecker).returns(false) if stub_no_typechecker

      if source
        server.process_message({
          method: "textDocument/didOpen",
          params: {
            textDocument: {
              uri: uri,
              text: source,
              version: 1
            }
          }
        })
      end

      server.global_state.index.index_single(
        RubyIndexer::IndexablePath.new(nil, uri.to_standardized_path),
        source
      )
      server.load_addons if load_addons
      block.call(server, uri)
    end
  ensure
    if load_addons
      RubyLsp::Addon.addons.each(&:deactivate)
      RubyLsp::Addon.addons.clear
    end
  end
end
