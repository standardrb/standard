require "pathname"

module Standard
  class Railtie < ::Rails::Railtie
    railtie_name :standard

    rake_tasks do
      load Pathname.new(__dir__).join("rake.rb")
    end
  end
end
