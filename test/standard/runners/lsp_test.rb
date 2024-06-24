require_relative "../../test_helper"

require "standard/runners/lsp"

class Standard::Runners::LspTest < UnitTest
  def test_server_initializes_and_responds_with_proper_capabilities
    msgs, err = run_server_on_requests({
      id: 2,
      jsonrpc: "2.0",
      method: "initialize",
      params: {probably: "don't need real params for this test?"}
    })

    assert_equal "", err.string
    assert_equal 1, msgs.count
    assert_equal msgs.first, {
      id: 2,
      result: {capabilities: {
        textDocumentSync: {openClose: true, change: 1},
        documentFormattingProvider: true
      }},
      jsonrpc: "2.0"
    }
  end

  def test_did_open
    msgs, err = run_server_on_requests({
      method: "textDocument/didOpen",
      jsonrpc: "2.0",
      params: {
        textDocument: {
          languageId: "ruby",
          text: "def hi\n  [1, 2,\n   3  ]\nend\n",
          uri: "file:///path/to/file.rb",
          version: 0
        }
      }
    })

    assert_equal "", err.string
    assert_equal 1, msgs.count

    expected = {
      method: "textDocument/publishDiagnostics",
      params: {
        uri: "file:///path/to/file.rb",
        diagnostics: [
          {
            range: {
              start: {line: 2, character: 3},
              end: {line: 2, character: 4}
            },
            severity: 3,
            code: "Layout/ArrayAlignment",
            codeDescription: {href: "https://docs.rubocop.org/rubocop/cops_layout.html#layoutarrayalignment"},
            source: "Standard Ruby",
            message: "Layout/ArrayAlignment: Use one level of indentation for elements following the first line of a multi-line array.",
            data: {
              correctable: true,
              code_actions: [
                {
                  title: "Autocorrect Layout/ArrayAlignment",
                  kind: "quickfix",
                  isPreferred: true,
                  edit: {
                    documentChanges: [
                      {
                        textDocument: {uri: "/path/to/file.rb", version: nil},
                        edits: [
                          {
                            range: {
                              start: {line: 2, character: 3},
                              end: {line: 2, character: 3}
                            }, newText: " "
                          }
                        ]
                      }
                    ]
                  }
                },
                {
                  title: "Disable Layout/ArrayAlignment for this line",
                  kind: "quickfix",
                  edit: {
                    documentChanges: [
                      {
                        textDocument: {uri: "/path/to/file.rb", version: nil},
                        edits: [
                          {
                            range: {
                              start: {line: 2, character: 7},
                              end: {line: 2, character: 7}
                            }, newText: " # standard:disable Layout/ArrayAlignment"
                          }
                        ]
                      }
                    ]
                  }
                }
              ]
            }
          },
          {
            range: {
              start: {line: 2, character: 4},
              end: {line: 2, character: 5}
            },
            severity: 3,
            code: "Layout/ExtraSpacing",
            codeDescription: {href: "https://docs.rubocop.org/rubocop/cops_layout.html#layoutextraspacing"},
            source: "Standard Ruby",
            message: "Layout/ExtraSpacing: Unnecessary spacing detected.",
            data: {
              correctable: true,
              code_actions: [
                {
                  title: "Autocorrect Layout/ExtraSpacing",
                  kind: "quickfix",
                  isPreferred: true,
                  edit: {
                    documentChanges: [
                      {
                        textDocument: {uri: "/path/to/file.rb", version: nil},
                        edits: [
                          {
                            range: {
                              start: {line: 2, character: 4},
                              end: {line: 2, character: 5}
                            }, newText: ""
                          }
                        ]
                      }
                    ]
                  }
                },
                {
                  title: "Disable Layout/ExtraSpacing for this line",
                  kind: "quickfix",
                  edit: {
                    documentChanges: [
                      {
                        textDocument: {uri: "/path/to/file.rb", version: nil},
                        edits: [
                          {
                            range: {
                              start: {line: 2, character: 7},
                              end: {line: 2, character: 7}
                            },
                            newText: " # standard:disable Layout/ExtraSpacing"
                          }
                        ]
                      }
                    ]
                  }
                }
              ]
            }
          },
          {
            range: {
              start: {line: 2, character: 4},
              end: {line: 2, character: 6}
            },
            severity: 3,
            code: "Layout/SpaceInsideArrayLiteralBrackets",
            codeDescription: {href: "https://docs.rubocop.org/rubocop/cops_layout.html#layoutspaceinsidearrayliteralbrackets"},
            source: "Standard Ruby",
            message: "Layout/SpaceInsideArrayLiteralBrackets: Do not use space inside array brackets.",
            data: {
              correctable: true,
              code_actions: [
                {
                  title: "Autocorrect Layout/SpaceInsideArrayLiteralBrackets",
                  kind: "quickfix",
                  isPreferred: true,
                  edit: {
                    documentChanges: [
                      {
                        textDocument: {uri: "/path/to/file.rb", version: nil},
                        edits: [
                          {
                            range: {
                              start: {line: 2, character: 4},
                              end: {line: 2, character: 6}
                            },
                            newText: ""
                          }
                        ]
                      }
                    ]
                  }
                },
                {
                  title: "Disable Layout/SpaceInsideArrayLiteralBrackets for this line",
                  kind: "quickfix",
                  edit: {
                    documentChanges: [
                      {
                        textDocument: {uri: "/path/to/file.rb", version: nil},
                        edits: [
                          {
                            range: {
                              start: {line: 2, character: 7},
                              end: {line: 2, character: 7}
                            },
                            newText: " # standard:disable Layout/SpaceInsideArrayLiteralBrackets"
                          }
                        ]
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      },
      jsonrpc: "2.0"
    }
    assert_equal expected, msgs.first
  end

  def test_format
    msgs, err = run_server_on_requests(
      {
        method: "textDocument/didOpen",
        jsonrpc: "2.0",
        params: {
          textDocument: {
            languageId: "ruby",
            text: "puts 'hi'",
            uri: "file:///path/to/file.rb",
            version: 0
          }
        }
      },
      {
        method: "textDocument/didChange",
        jsonrpc: "2.0",
        params: {
          contentChanges: [{text: "puts 'bye'"}],
          textDocument: {
            uri: "file:///path/to/file.rb",
            version: 10
          }
        }
      },
      {
        method: "textDocument/formatting",
        id: 20,
        jsonrpc: "2.0",
        params: {
          options: {insertSpaces: true, tabSize: 2},
          textDocument: {uri: "file:///path/to/file.rb"}
        }
      }
    )

    assert_equal "", err.string
    format_result = msgs.last
    assert_equal(
      {
        id: 20,
        result: [
          {newText: "puts \"bye\"\n",
           range: {
             start: {line: 0, character: 0},
             end: {line: 1, character: 0}
           }}
        ],
        jsonrpc: "2.0"
      },
      format_result
    )
  end

  def test_no_op_commands
    _, err = run_server_on_requests(
      {
        method: "$/cancelRequest",
        id: 1,
        jsonrpc: "2.0",
        params: {}
      },
      {
        method: "$/setTrace",
        id: 1,
        jsonrpc: "2.0",
        params: {}
      }
    )

    assert_empty err.string
  end

  def test_initialized
    _, err = run_server_on_requests(
      {
        method: "initialized",
        id: 1,
        jsonrpc: "2.0",
        params: {}
      }
    )

    assert_match(/Standard Ruby v\d+.\d+.\d+ LSP server initialized, pid \d+/, err.string)
  end

  def test_format_with_unsynced_file
    msgs, err = run_server_on_requests(
      {
        method: "textDocument/didOpen",
        jsonrpc: "2.0",
        params: {
          textDocument: {
            languageId: "ruby",
            text: "def hi\n  [1, 2,\n   3  ]\nend\n",
            uri: "file:///path/to/file.rb",
            version: 0
          }
        }
      },
      # didClose should cause the file to be unsynced
      {
        method: "textDocument/didClose",
        jsonrpc: "2.0",
        params: {
          textDocument: {
            uri: "file:///path/to/file.rb"
          }
        }
      },
      {
        method: "textDocument/formatting",
        id: 20,
        jsonrpc: "2.0",
        params: {
          options: {insertSpaces: true, tabSize: 2},
          textDocument: {uri: "file:///path/to/file.rb"}
        }
      }
    )

    assert_equal "[server] Format request arrived before text synchonized; skipping: `file:///path/to/file.rb'", err.string.chomp
    format_result = msgs.last
    assert_equal(
      {
        id: 20,
        result: [],
        jsonrpc: "2.0"
      },
      format_result
    )
  end

  def test_unknown_commands
    msgs, err = run_server_on_requests(
      {
        id: 18,
        method: "textDocument/didMassage",
        jsonrpc: "2.0",
        params: {
          textDocument: {
            languageId: "ruby",
            text: "def hi\n  [1, 2,\n   3  ]\nend\n",
            uri: "file:///path/to/file.rb",
            version: 0
          }
        }
      }
    )

    assert_equal "[server] Unsupported Method: textDocument/didMassage", err.string.chomp
    assert_equal({
      id: 18,
      error: {
        code: -32601,
        message: "Unsupported Method: textDocument/didMassage"
      },
      jsonrpc: "2.0"
    }, msgs.last)
  end

  def test_methodless_requests_are_acked
    msgs, err = run_server_on_requests(
      {
        id: 1,
        jsonrpc: "2.0",
        result: {}
      }
    )

    assert_equal "", err.string
    assert_equal({
      id: 1,
      jsonrpc: "2.0",
      result: nil
    }, msgs.last)
  end

  def test_methodless_and_idless_requests_are_dropped
    msgs, err = run_server_on_requests(
      {
        jsonrpc: "2.0",
        result: {}
      }
    )

    assert_equal "", err.string
    assert_empty msgs
  end

  def test_execute_command_formatting
    msgs, err = run_server_on_requests(
      {
        method: "textDocument/didOpen",
        jsonrpc: "2.0",
        params: {
          textDocument: {
            languageId: "ruby",
            text: "puts 'hi'",
            uri: "file:///path/to/file.rb",
            version: 0
          }
        }
      },
      {
        method: "workspace/executeCommand",
        id: 99,
        jsonrpc: "2.0",
        params: {
          command: "standardRuby.formatAutoFixes",
          arguments: [{uri: "file:///path/to/file.rb"}]
        }
      }
    )

    assert_equal "", err.string
    assert_equal({
      id: 99,
      method: "workspace/applyEdit",
      params: {
        label: "Format with Standard Ruby auto-fixes",
        edit: {
          changes: {
            "file:///path/to/file.rb": [{
              newText: "puts \"hi\"\n",
              range: {
                start: {line: 0, character: 0},
                end: {line: 1, character: 0}
              }
            }]
          }
        }
      },
      jsonrpc: "2.0"
    }, msgs.last)
  end

  def test_execute_command_with_unsupported_command
    msgs, err = run_server_on_requests(
      {
        method: "workspace/executeCommand",
        id: 99,
        jsonrpc: "2.0",
        params: {
          command: "standardRuby.somethingElse",
          arguments: [{uri: "file:///path/to/file.rb"}]
        }
      }
    )

    assert_equal "[server] Unsupported Method: standardRuby.somethingElse", err.string.chomp
    assert_equal({
      id: 99,
      error: {
        code: -32601,
        message: "Unsupported Method: standardRuby.somethingElse"
      },
      jsonrpc: "2.0"
    }, msgs.last)
  end

  def test_did_open_on_ignored_path
    msgs, err = run_server_on_requests({
      method: "textDocument/didOpen",
      jsonrpc: "2.0",
      params: {
        textDocument: {
          languageId: "ruby",
          text: "puts 'neat'",
          # Depends on this project's .standard.yml ignoring `tmp/**/*`
          uri: "file://#{Dir.pwd}/tmp/foo/bar.rb",
          version: 0
        }
      }
    })

    assert_equal 1, msgs.count
    assert_equal({
      method: "textDocument/publishDiagnostics",
      params: {
        diagnostics: [],
        uri: "file://#{Dir.pwd}/tmp/foo/bar.rb"
      },
      jsonrpc: "2.0"
    }, msgs.first)
  end

  def test_formatting_via_execute_command_on_ignored_path
    msgs, err = run_server_on_requests(
      {
        method: "textDocument/didOpen",
        jsonrpc: "2.0",
        params: {
          textDocument: {
            languageId: "ruby",
            text: "puts 'hi'",
            # Depends on this project's .standard.yml ignoring `tmp/**/*`
            uri: "file://#{Dir.pwd}/tmp/baz.rb",
            version: 0
          }
        }
      },
      {
        method: "workspace/executeCommand",
        id: 99,
        jsonrpc: "2.0",
        params: {
          command: "standardRuby.formatAutoFixes",
          arguments: [{uri: "file://#{Dir.pwd}/tmp/baz.rb"}]
        }
      }
    )

    assert_equal({
      id: 99,
      method: "workspace/applyEdit",
      params: {
        label: "Format with Standard Ruby auto-fixes",
        edit: {
          changes: {
            "file://#{Dir.pwd}/tmp/baz.rb": []
          }
        }
      },
      jsonrpc: "2.0"
    }, msgs.last)
  end

  def test_formatting_via_formatting_path_on_ignored_path
    msgs, err = run_server_on_requests(
      {
        method: "textDocument/didOpen",
        jsonrpc: "2.0",
        params: {
          textDocument: {
            languageId: "ruby",
            text: "puts 'hi'",
            # Depends on this project's .standard.yml ignoring `tmp/**/*`
            uri: "file://#{Dir.pwd}/tmp/zzz.rb",
            version: 0
          }
        }
      },
      {
        method: "textDocument/didChange",
        jsonrpc: "2.0",
        params: {
          contentChanges: [{text: "puts 'bye'"}],
          textDocument: {
            uri: "file://#{Dir.pwd}/tmp/zzz.rb",
            version: 10
          }
        }
      },
      {
        method: "textDocument/formatting",
        id: 20,
        jsonrpc: "2.0",
        params: {
          options: {insertSpaces: true, tabSize: 2},
          textDocument: {uri: "file://#{Dir.pwd}/tmp/zzz.rb"}
        }
      }
    )

    format_result = msgs.last
    assert_equal(
      {
        id: 20,
        result: [],
        jsonrpc: "2.0"
      },
      format_result
    )
  end

  private

  def run_server_on_requests(*requests)
    stdin = StringIO.new(requests.map { |r| to_jsonrpc(r) }.join)
    out, err, _ = do_with_fake_io(stdin) do
      Standard::Runners::Lsp.new.call(create_config)
    end

    msgs = parse_jsonrpc_messages(out)

    [msgs, err]
  end

  BASE_CONFIG = Standard::BuildsConfig.new.call(["-a", "some_file_name.rb"])

  def create_config(options = {})
    Standard::Config.new(nil, ["unused_file_name.rb"], options, BASE_CONFIG.rubocop_config_store)
  end

  def to_jsonrpc(hash)
    hash_str = hash.to_json

    "Content-Length: #{hash_str.bytesize}\r\n\r\n#{hash_str}"
  end

  def parse_jsonrpc_messages(io)
    io.rewind
    reader = LanguageServer::Protocol::Transport::Io::Reader.new(io)
    messages = []
    reader.read { |msg| messages << msg }
    messages
  end
end
