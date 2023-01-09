require_relative "../test_helper"

class Standard::LoadsRunnerTest < UnitTest
  def setup
    @subject = Standard::LoadsRunner.new
  end

  def test_rubocop
    result = @subject.call(:rubocop)

    assert_instance_of ::Standard::Runners::Rubocop, result
  end

  def test_version
    result = @subject.call(:version)

    assert_instance_of ::Standard::Runners::Version, result
  end

  def test_verbose_version
    result = @subject.call(:verbose_version)

    assert_instance_of ::Standard::Runners::VerboseVersion, result
  end

  def test_lsp
    result = @subject.call(:lsp)

    assert_instance_of ::Standard::Runners::Lsp, result
  end

  def test_genignore
    result = @subject.call(:genignore)

    assert_instance_of ::Standard::Runners::Genignore, result
  end

  def test_help
    result = @subject.call(:help)

    assert_instance_of ::Standard::Runners::Help, result
  end
end
