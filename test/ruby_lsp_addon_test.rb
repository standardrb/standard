require "ruby_lsp/internal"
require "test_helper"
require "ruby_lsp/standard/addon"

class RubyLspAddonTest < UnitTest
  def setup
    @addon = RubyLsp::Standard::Addon.new
    super
  end

  def test_name
    assert_equal "Standard Ruby", @addon.name
  end

  def test_format
    source = <<~RUBY
      s = 'hello'
      puts s
    RUBY
    with_server(source, "test/fixture/ruby_lsp/simple.rb") do |server, uri|
      server.process_message(
        id: 1,
        method: "textDocument/formatting",
        params: {textDocument: {uri: uri}, position: {line: 0, character: 0}}
      )

      result = server.pop_response

      assert_instance_of(RubyLsp::Result, result)
      assert 1, result.response.size
      assert_equal({
        range: RubyLsp::Interface::Range.new(
          start: RubyLsp::Interface::Position.new(line: 0, character: 0),
            # Fails! Actual is line: 19, character: 19??????
          end: RubyLsp::Interface::Position.new(line: 2, character: 5)
        ),
        newText: <<~RUBY
          s = "hello"
          puts s
        RUBY
      }, result.response.first.to_hash)
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
      server.global_state.formatter = "standard" # <-- TODO this should work, right?
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
