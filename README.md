# Rlimiter

Rlimiter is a simple rate limiting client for Ruby (not limited to RoR!).

The fundamental idea behind this client is to limit the number of hits of any code within the application. Hence it is not
only limited to API rate limiting, instead can be used in all sorts of scenarios that require circumstantial throttling of throughput.

It currently uses Redis as the main storage client for storing the necessary keys, provided it's fast IO operations and ubiquity in web applications. It is written
in a manner to effortlessly extend and implement custom storage clients as required.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rlimiter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rlimiter

## Usage

Rlimiter has to be initialized in application.rb if you are using Rails, or any other bootstrap/initialization file in your application by doing the following:   
```ruby

CLIENT = 'redis' # Recommended and the only client for now
HOST = 'rds.host.foobaz' # Redis server hostname, enter 'localhost' if the redis server is on the same machine
PORT = 6379 # Default port, could be left empty

# Initializes the Rlimiter static class for usage  
Rlimiter.init(client: CLIENT, host: HOST, port: PORT)
```

There is one common way to use Rlimiter (which suffices most of the use cases)

```ruby

  LIMIT_COUNT = 100 # Max number of hits allowed
  
  LIMIT_DURATION = 60 # Duration in which the max hits are applicable (in seconds)
  # After the aforementioned duration has elapsed, hit counter is reset to 0. 
  
  LIMIT_KEY = 'send_mobile_otp_limit' # Unique key for each operation that has to be rate limited
  
  
  # Implementation
  
  return send_mobile_otp if Rlimiter.limit(LIMIT_KEY, LIMIT_COUNT, LIMIT_DURATION)
  return limit_exceeded_message
  
  # :send_mobile_otp is the function that has to be rate limited, Rlimiter.limit call increments the hit count and 
  # returns true if the operation's limit has not been exceeded, otherwise returns false. 
```

A more complicated approach could also be implemented :

```ruby
    
    @phone_number = '2947126943'
    @limit_key = generate_limit_key
    @limit_count = fetch_limit_count
    limit_breached = Rlimiter.limit(@limit_key, @limit_count, DEFAULT_LIMIT_DURATION)
    unless limit_breached
      {
        :status_code => 200,
        :otp_dispatch_status => send_mobile_otp,
        :requests_left => @limit_count - Rlimiter.current_count(@limit_key)
      }
    else
      {
        :status_code => 429,
        :otp_dispatch_status => nil,
        :requests_left => 0,
        :next_request_in => Rlimiter.next_in(@limit_key, DEFAULT_LIMIT_DURATION)
      }
    end
    
    # ..........
    
    def generate_limit_key
      "#{LIMIT_KEY_PREFIX}.#{@phone_number}"
    end
    
    def fetch_limit_count
      return USA_LIMIT_COUNT if number_from_usa?(@phone_number)
      return INDIA_LIMIT_COUNT if number_from_india?(@phone_number)
      DEFAULT_LIMIT_COUNT  
    end
    
    # ..........
    
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### TODOs:

1. Write specs for 100% code coverage.
2. Add benchmarks.
3. Integrate Travis.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sdpatro/rlimiter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rlimiter project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sdpatro/rlimiter/blob/master/CODE_OF_CONDUCT.md).
