require 'spec_helper'

RSpec.describe Rlimiter::RedisClient do

  subject { Rlimiter::RedisClient }
  let(:redis) { double(Redis) }

  describe '#initialize' do
    it 'should initialize Redis with the params provided' do
      params = {host: 'test_host', port: rand(10**4), db: rand(10**1)}
      expect(Redis).to receive(:new).with(params).and_return(redis)
      expect(subject.new(params).instance_variable_get(:@redis)).to eq(redis)
    end
  end

  describe '#limit' do
    it 'return true ' do

    end
  end

end
