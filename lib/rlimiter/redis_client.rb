require 'redis'

module Rlimiter
  class RedisClient < Client
    RATE_COUNT = 'rate_count'.freeze
    START_TIME = 'start_time'.freeze

    def initialize
      @redis = Redis.new(host: 'localhost', port: 6379)
    end

    def limit(key, count, duration)
      @key = key
      @duration = duration
      curr_count_cache = curr_count

      if curr_count_cache > count
        raise LimitExceededError unless elapsed > @duration
        self.curr_count = 1
        reset_time
      else
        self.curr_count = (curr_count_cache + 1)
      end

      yield

    end

    private

    def reset_time
      self.start_time = Time.utc.to_f * 1000
    end

    def start_time=(time)
      @redis.hset(@key, START_TIME, time)
    end

    def curr_count=(count)
      @redis.hset(@key, RATE_COUNT, count)
    end

    def curr_count
      @redis.hget(@key, RATE_COUNT).to_i
    end

    def elapsed
      ((Time.now.to_f * 1000 - start_time) / 1000).to_i
    end

    def start_time
      @redis.hget(@key, START_TIME).to_i
    end
  end
end
