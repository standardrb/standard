require "pathname"

module Standard
  class FileFinder
    def call(name, search_path)
      Pathname.new(search_path).expand_path.ascend do |path|
        if (file = path + name).exist?
          return file.to_s
        end
      end
    end
  end
end
