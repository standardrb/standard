module Standard
  class DetectsFixability
    def call(offenses)
      offenses.any? { |offense|
        cop = cop_instance(offense.cop_name)
        cop.support_autocorrect? && safe?(cop)
      }
    end

    private

    def cop_instance(cop_name)
      RuboCop::Cop.const_get(cop_name.gsub("/", "::")).new
    end

    def safe?(cop)
      cop.cop_config.fetch("SafeAutoCorrect", true)
    end
  end
end
