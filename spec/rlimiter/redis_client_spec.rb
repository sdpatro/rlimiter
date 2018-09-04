require 'spec_helper'

RSpec.describe Rlimiter::RedisClient do
  describe '#limit' do
    it 'should limit the number of executions of the code block provided' do
      Rlimiter.init(client: 'redis', host: 'localhost', port: 6379)
      10.times {
        puts Rlimiter.limit('test_key', 10, 10)
        puts Rlimiter.next_in('test_key', 10, 10)
      }
    end
  end
end
