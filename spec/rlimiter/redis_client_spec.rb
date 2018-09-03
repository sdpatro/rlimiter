require 'spec_helper'

RSpec.describe Rlimiter::RedisClient do
  describe '#limit' do
    it 'should limit the number of executions of the code block provided' do
      Rlimiter.init(client: 'redis', host: 'localhost', port: 6379)
      10.times {
        Rlimiter.limit('test_key', 10, 10) do
          puts 'test code block'
        end
      }
    end
  end
end
