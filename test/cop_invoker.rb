# Most of this was adapted from Rubocop's
#
# lib/rubocop/rspec/expect_offense.rb
module CopInvoker
  RUBY_VERSION = 2.6

  # Usage:
  #
  #   assert_offense(<<~RUBY)
  #     a do
  #       b
  #     end.c
  #     ^^^^^ Avoid chaining a method call on a do...end block.
  #   RUBY
  #
  def assert_offense(cop, source)
    RuboCop::Formatter::DisabledConfigFormatter.config_to_allow_offenses = {}
    RuboCop::Formatter::DisabledConfigFormatter.detected_styles = {}
    cop.instance_variable_get(:@options)[:autocorrect] = true
    expected = AnnotatedSource.parse(source)

    @last_source = RuboCop::ProcessedSource.new(
      expected.plain_source, RUBY_VERSION, nil
    )

    raise "Error parsing example code" unless @last_source.valid_syntax?

    offenses = _investigate(cop, @last_source)

    actual_annotations = expected.with_offense_annotations(offenses)
    assert_equal expected.to_s, actual_annotations.to_s
  end

  # Auto-correction can be tested using `assert_correction` after
  # `assert_offense`:
  #
  #   assert_offense(<<~RUBY)
  #     x % 2 == 0
  #     ^^^^^^^^^^ Replace with `Integer#even?`.
  #   RUBY
  #
  #   assert_correction(<<~RUBY)
  #     x.even?
  #   RUBY
  #
  def assert_correction(cop, expected)
    raise "`assert_correction` must follow `assert_offense`" unless @last_source

    iteration = 0
    actual = loop do
      iteration += 1

      corrected_source = @last_corrector.rewrite

      break corrected_source unless loop
      break corrected_source if @last_corrector.empty?
      break corrected_source if corrected_source == @processed_source.buffer.source

      if iteration > RuboCop::Runner::MAX_ITERATIONS
        raise RuboCop::Runner::InfiniteCorrectionLoop.new(@processed_source.path, [])
      end

      # Prepare for next loop
      @processed_source = parse_source(corrected_source,
        @processed_source.path)
      _investigate(cop, @processed_source)
    end

    assert_equal expected, actual
  end

  def assert_no_correction(cop)
    raise "`assert_no_correction` must follow `assert_offense`" unless @last_source

    return if cop.corrections.empty?

    actual = RuboCop::Cop::Corrector.new(@last_source.buffer, cop.corrections).rewrite

    assert_equal @last_source.buffer.source, actual
  end

  def assert_no_offense(cop, source)
    RuboCop::Formatter::DisabledConfigFormatter.config_to_allow_offenses = {}
    RuboCop::Formatter::DisabledConfigFormatter.detected_styles = {}
    processed_source = RuboCop::ProcessedSource.new(source, RUBY_VERSION, nil)

    raise "Error parsing example code" unless processed_source.valid_syntax?

    offenses = _investigate(cop, processed_source)

    assert_equal [], offenses
  end

  # Parsed representation of code annotated with the `^^^ Message` style
  class AnnotatedSource
    ANNOTATION_PATTERN = /\A\s*\^+ /

    # @param annotated_source [String] string passed to the matchers
    #
    # Separates annotation lines from source lines. Tracks the real
    # source line number that each annotation corresponds to.
    #
    # @return [AnnotatedSource]
    def self.parse(annotated_source)
      source = []
      annotations = []

      annotated_source.each_line do |source_line|
        if ANNOTATION_PATTERN.match?(source_line)
          annotations << [source.size, source_line]
        else
          source << source_line
        end
      end

      new(source, annotations)
    end

    # @param lines [Array<String>]
    # @param annotations [Array<(Integer, String)>]
    #   each entry is the annotated line number and the annotation text
    #
    # @note annotations are sorted so that reconstructing the annotation
    #   text via {#to_s} is deterministic
    def initialize(lines, annotations)
      @lines = lines.freeze
      @annotations = annotations.sort.freeze
    end

    # Construct annotated source string (like what we parse)
    #
    # Reconstruct a deterministic annotated source string. This is
    # useful for eliminating semantically irrelevant annotation
    # ordering differences.
    #
    # @example standardization
    #
    #     source1 = AnnotatedSource.parse(<<-RUBY)
    #     line1
    #     ^ Annotation 1
    #      ^^ Annotation 2
    #     RUBY
    #
    #     source2 = AnnotatedSource.parse(<<-RUBY)
    #     line1
    #      ^^ Annotation 2
    #     ^ Annotation 1
    #     RUBY
    #
    #     source1.to_s == source2.to_s # => true
    #
    # @return [String]
    def to_s
      reconstructed = lines.dup

      annotations.reverse_each do |line_number, annotation|
        reconstructed.insert(line_number, annotation)
      end

      reconstructed.join
    end

    # Return the plain source code without annotations
    #
    # @return [String]
    def plain_source
      lines.join
    end

    # Annotate the source code with the RuboCop offenses provided
    #
    # @param offenses [Array<RuboCop::Cop::Offense>]
    #
    # @return [self]
    def with_offense_annotations(offenses)
      offense_annotations =
        offenses.map do |offense|
          indent = " " * offense.column
          carets = "^" * offense.column_length

          [offense.line, "#{indent}#{carets} #{offense.message}\n"]
        end

      self.class.new(lines, offense_annotations)
    end

    private

    attr_reader :lines, :annotations
  end

  def _investigate(cop, processed_source)
    team = RuboCop::Cop::Team.new([cop], nil, raise_error: true)
    report = team.investigate(processed_source)
    @processed_source = processed_source
    @last_corrector = report.correctors.first || RuboCop::Cop::Corrector.new(processed_source)
    report.offenses
  end

  def parse_source(source, file = nil)
    if file&.respond_to?(:write)
      file.write(source)
      file.rewind
      file = file.path
    end

    RuboCop::ProcessedSource.new(source, RUBY_VERSION, file)
  end
end
