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
        return false if @duration - elapsed > 0
        reset
      end
      true
    end

    def current_count(key)
      @redis.hget(key, RATE_COUNT).to_i
    end

    def next_in(key, count, duration)
      @key = key
      @duration = duration
      return 0 if current_count(key) <= count
      @duration - elapsed
    end

    private

    def reset
      @redis.hmset(@key, RATE_COUNT, 1, START_TIME, Time.now.getutc.to_f * 1000)
    end

    def incr_count
      @redis.hincrby(@key, RATE_COUNT, 1)
    end

    def elapsed
      ((Time.now.getutc.to_f * 1000 - start_time) / 1000).to_i
    end

    def start_time
      @redis.hget(@key, START_TIME).to_i
    end
  end
end
