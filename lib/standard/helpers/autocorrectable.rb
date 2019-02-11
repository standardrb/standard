module Standard
  module Helpers
    module Autocorrectable
      def autocorrectable_offense?(offense)
        cop = cop_instance(offense.cop_name)
        cop.support_autocorrect? && safely_autocorrectable?(cop)
      end

      def cop_instance(cop_name)
        constantized_cop(cop_name).new
      end

      def constantized_cop(cop_name)
        namespaced_cop_class = cop_name.to_s.gsub("/", "::")
        RuboCop::Cop.const_get(namespaced_cop_class)
      end

      def safely_autocorrectable?(cop)
        return true unless cop.cop_config
        cop.cop_config.fetch("SafeAutoCorrect", true)
      end
    end
  end
end
