require "benchmark"

module Standard
  class Timer
    def time
      result = false
      time = Benchmark.realtime do
        result = yield
      end
      [time, result]
    end
  end
end
