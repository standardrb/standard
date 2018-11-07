require "benchmark"

module Standard
  class Timer
    def time(&blk)
      result = false
      time = Benchmark.realtime do
        result = blk.call
      end
      [time, result]
    end
  end
end

