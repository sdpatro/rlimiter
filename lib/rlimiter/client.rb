# Inherit the below class for custom implementations of any storage clients.
module Rlimiter
  class Client

    def limit(key, count, duration)
      # Stub
    end

    def next_in(key, duration)
      # Stub
    end

    def current_count(key)
      # Stub
    end

  end
end