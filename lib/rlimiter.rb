require 'rlimiter/version'

# It is important that the files are loaded in the order specified below because of inheritance dependencies.
# TODO: Figure out a better way to load
require_files = %w[/rlimiter/client.rb /rlimiter/invalid_client_error.rb /rlimiter/version.rb /rlimiter/redis_client.rb]
require_files.each do |file|
  Dir.glob(File.dirname(File.absolute_path(__FILE__)) + file, &method(:require))
end

# Module which is single-instantiated in the application via :init.
module Rlimiter
  class << self

    # At the moment only redis client is supported.
    CLIENTS = %w[redis].freeze
    attr_accessor :client

    # One time initializes the client which is to be used throughout the application.
    # The value of params variable will change depending on the storage client to be initialized.
    # @param [Hash] params
    # @return [Rlimiter::Client]
    def init(params)
      case params[:client]
      when 'redis'
        @client = RedisClient.new(params)
      else
        raise InvalidClientError, "Valid clients are #{CLIENTS.join(',')}"
      end
    end

    # Note : Params for the below methods are kept arbitrary for free implementation and are specific to a single client,
    # after usage feedback it will be refactored to pertain to a single signature.

    # Register a hit to the client.
    def limit(*params)
      client.limit(*params)
    end

    # Returns when the next hit will be accepted
    def next_in(*params)
      client.next_in(*params)
    end

    # Returns the current hit count.
    def current_count(*params)
      client.current_count(*params)
    end
  end
end
