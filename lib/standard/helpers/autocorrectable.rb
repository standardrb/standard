module Standard
  module Helpers
    module Autocorrectable
      def autocorrectable_offense?(offense)
        cop_instance(offense.cop_name).support_autocorrect?
      end

      def cop_instance(cop_name)
        constantized_cop(cop_name).new
      end

      def constantized_cop(cop_name)
        namespaced_cop_class = cop_name.to_s.gsub("/", "::")
        RuboCop::Cop.const_get(namespaced_cop_class)
      end
    end
  end
end
