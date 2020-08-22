module Standard
  class DetectsFixability
    def call(offenses)
      offenses.any? { |offense|
        cop = cop_instance(offense.cop_name)
        cop.correctable? && cop.safe_autocorrect?
      }
    end

    private

    def cop_instance(cop_name)
      RuboCop::Cop.const_get(cop_name.gsub("/", "::")).new
    end
  end
end
