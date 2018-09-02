require 'spec_helper'

RSpec.describe Rlimiter::RedisClient do
  describe '#limit' do
    it 'should limit the number of executions of the code block provided' do
      Rlimiter::RedisClient.new.limit('test_key', 100, 10) do
        puts 'test block of code'
      end
    end
  end
end
