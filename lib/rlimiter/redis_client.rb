require 'redis'

module Rlimiter
  # Redis concrete class of abstract Client
  # Maintains two redis keys, one for number of hits and other for the start of
  # the time window.
  # Increases the hit count every time :limit is called, if hit count exceeds
  # the limit count then it is checked whether
  # if the previous time window is active or not, on the basis of which
  # true/false is returned.
  class RedisClient < Client
    # Name of key of the hit count number, stores an integer.
    RATE_COUNT = 'rate_count'.freeze

    # Name of key of the start time of the time window, stores the UTC epoch time.
    START_TIME = 'start_time'.freeze

    # Initializes and returns a Redis object.
    #
    # Requires params hash i.e.
    # {
    #   :host => [String] (The hostname of the Redis server)
    #   :port => [String] (Numeric port number)
    # }
    #
    # For further documentation refer to https://github.com/redis/redis-rb
    #
    # Any errors thrown are generated by the redis-rb client.
    #
    # @param [Hash] params
    # @return [Redis]
    #
    def initialize(params)
      @redis = Redis.new(params)
    end

    # Registers a hit corresponding to the key specified, requires the max hit
    # count and the duration to be passed.
    #
    # @param [String] key : Should be unique for one operation, can be added for
    # multiple operations if a single rate
    #                       limiter is to be used for those operations.
    # @param [Integer] count : Max rate limit count
    # @param [Integer] duration : Duration of the time window.
    #
    # Count and duration params could change in each call and the limit breach
    # value is returned corresponding to that.
    # Ideally this method should be called with each param a constant on the
    # application level.
    #
    # Returns false if the limit has been breached.
    # Returns true if limit has not been breached. (duh)
    def limit(key, count, duration)
      @key = key.to_s
      @duration = duration.to_i

      # :incr_count increases the hit count and simultaneously checks for breach
      if incr_count > count

        # :elapsed is the time window start Redis cache
        # If the time elapsed is less than window duration, the limit has been
        # breached for the current window (return false).
        return false if @duration - elapsed > 0

        # Else reset the hit count to zero and window start time.
        reset
      end
      true
    end

    # Gets the hit count for the key passed.
    # @param [Integer] key
    def current_count(key)
      @redis.hget(key, RATE_COUNT).to_i
    end

    # Gets the ETA for the next window start only if the limit has been breached.
    # Returns 0 if the limit has not been breached.
    # @param [String] key
    # @param [Integer] count
    # @param [Integer] duration
    def next_in(key, count, duration)
      @key = key
      @duration = duration
      return 0 if current_count(key) < count

      [@duration - elapsed, 0].max
    end

    # Clear the key from the data store.
    # @param [String] key
    # @return [TrueClass|FalseClass] depending on whether key has been deleted
    # successfully.
    def clear(key)
      @redis.del(key) == 1
    end

    private

    def reset
      @redis.hmset(@key, RATE_COUNT, 1, START_TIME, Time.now.getutc.to_f * 1000)
    end

    def incr_count
      @redis.hincrby(@key, RATE_COUNT, 1)
    end

    def elapsed
      ((Time.now.getutc.to_time.to_i * 1000 - start_time) / 1000).to_i
    end

    def start_time
      @redis.hget(@key, START_TIME).to_i
    end
  end
end
