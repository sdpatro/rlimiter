require 'rlimiter/version'
require_files = %w[/rlimiter/client.rb /rlimiter/invalid_client_error.rb /rlimiter/version.rb /rlimiter/redis_client.rb]
require_files.each do |file|
  Dir.glob(File.dirname(File.absolute_path(__FILE__)) + file, &method(:require))
end

module Rlimiter
  class << self
    CLIENTS = %w[redis].freeze
    attr_accessor :client

    def init(params)
      case params[:client]
      when 'redis'
        @client = RedisClient.new(params)
      else
        raise InvalidClientError, "Valid clients are #{CLIENTS.join(',')}"
      end
    end

    def limit(*params)
      client.limit(*params)
    end

    def next_in(*params)
      client.next_in(*params)
    end

    def current_count(*params)
      client.current_count(*params)
    end
  end
end
