require 'spec_helper'

RSpec.describe Rlimiter::RedisClient do
  describe '#limit' do
    it 'should limit the number of executions of the code block provided' do
      10.times {
        Rlimiter::RedisClient.new.limit('test_key', 10, 10) {puts 'test block of code'}
        sleep 0.1
      }
    end
  end
end
