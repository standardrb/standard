require "test_helper"

module Standard
  module PluginSupport
    class MergesUpstreamMetadataTest < Minitest::Test
      def setup
        @subject = MergesUpstreamMetadata.new
      end

      def test_no_op
        assert_equal({}, @subject.merge({}, {}))
        assert_equal({}, @subject.merge({}, {:junk => {}, "Some/Rule" => {}}))
        assert_equal({foo: "berry"}, @subject.merge({foo: "berry"}, {:junk => {}, "Some/Rule" => {}}))
      end

      def test_merges_undefined_sub_keys
        assert_equal(
          {"Some/Rule" => {"Enabled" => true, "Description" => "foo"}},
          @subject.merge(
            {"Some/Rule" => {"Enabled" => true}},
            {"Some/Rule" => {"Description" => "foo"}}
          )
        )
      end

      def test_doesnt_merge_nil_values
        assert_equal(
          {"Some/Rule" => {"Description" => nil}},
          @subject.merge(
            {"Some/Rule" => {"Description" => nil}},
            {"Some/Rule" => {"Description" => "foo"}}
          )
        )
      end

      def test_doesnt_override_defined_values
        assert_equal(
          {"Some/Rule" => {"Enabled" => false}},
          @subject.merge(
            {"Some/Rule" => {"Enabled" => false}},
            {"Some/Rule" => {"Enabled" => true}}
          )
        )
      end

      def test_doesnt_munge_arrays
        assert_equal(
          {"Some/Rule" => {"Included" => ["lol"]}},
          @subject.merge(
            {"Some/Rule" => {"Included" => ["lol"]}},
            {"Some/Rule" => {"Included" => ["kek"]}}
          )
        )
      end

      def test_doesnt_munge_hashes
        assert_equal(
          {"Some/Rule" => {"Conf" => {a: 1}}},
          @subject.merge(
            {"Some/Rule" => {"Conf" => {a: 1}}},
            {"Some/Rule" => {"Conf" => {a: 2, b: 3}}}
          )
        )
      end
    end
  end
end
