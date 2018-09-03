require 'redis'

module Rlimiter

  class RedisClient < Client

    RATE_COUNT = 'rate_count'.freeze
    START_TIME = 'start_time'.freeze

    def initialize(params)
      @redis = Redis.new(params)
    end

    def limit(key, count, duration)
      @key = key
      @duration = duration

      if incr_count > count
        time_diff = @duration - elapsed
        time_diff > 0 && raise_limit_error(time_diff)
        reset_count
        reset_time
      end

      yield

    end

    private

    def reset_count
      self.curr_count = 1
    end

    def incr_count
      @redis.hincrby(@key, RATE_COUNT, 1)
    end

    def raise_limit_error(time_diff)
      raise Rlimiter::LimitExceededError, time_diff
    end

    def reset_time
      self.start_time = Time.now.getutc.to_f * 1000
    end

    def start_time=(time)
      @redis.hset(@key, START_TIME, time)
    end

    def curr_count=(count)
      @redis.hset(@key, RATE_COUNT, count)
    end

    def elapsed
      ((Time.now.to_f * 1000 - start_time) / 1000).to_i
    end

    def start_time
      @redis.hget(@key, START_TIME).to_i
    end
  end
end
