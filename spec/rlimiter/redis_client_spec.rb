require 'spec_helper'
require 'timecop'

RSpec.describe Rlimiter::RedisClient do

  let(:redis) {double(Redis)}
  subject {Rlimiter::RedisClient}
  let(:key) {'test_key'}

  def mock_hincrby(redis, count)
    allow(redis).to receive(:hincrby).with(key, Rlimiter::RedisClient::RATE_COUNT, 1).and_return(count + 1)
  end

  def mock_start_time(redis, time)
    allow(redis).to receive(:hget).with(key, Rlimiter::RedisClient::START_TIME).and_return(time)
  end

  describe '#initialize' do
    it 'should return a Redis object created with the params passed' do
      params = {:host => 'testhost', :port => rand(10 ** 4)}
      expect(Redis).to receive(:new).with(params).and_return(redis)
      subject_obj = subject.new(params)
      expect(subject_obj.instance_variable_get(:@redis)).to eq(redis)
    end
  end

  describe '#limit' do

    let(:max_count) {rand(10 ** 2) + 1}
    let(:time_start) {DateTime.parse('2018-08-09 15:06:34+00:00')}
    let(:time_now) {DateTime.parse('2018-08-09 15:07:04+00:00')}

    before :each do
      allow(Redis).to receive(:new).and_return(redis)
      @mock_subject = subject.new({})
      Timecop.freeze(time_now)
    end

    it 'should return false if limit has been breached' do
      mock_hincrby(redis, max_count + 1)
      mock_start_time(redis, time_start.to_time.to_i * 1000)
      expect(@mock_subject.limit(key, max_count, 31)).to eq(false)
    end

    it 'should return true if limit is not breached (count is less than max count)' do
      mock_hincrby(redis, max_count - 1)
      mock_start_time(redis, time_start.to_time.to_i * 1000)
      expect(@mock_subject.limit(key, max_count, 30)).to eq(true)
    end

    it 'should return true if limit is not breached (limit exceeds and duration is greater than window)' do
      mock_hincrby(redis, max_count + 1)
      mock_start_time(redis, time_start.to_time.to_i * 1000)
      expect(redis).to receive(:hmset).with(key, 'rate_count', 1, 'start_time', time_now.to_time.to_i * 1000)
      expect(@mock_subject.limit(key, max_count, 29)).to eq(true)
    end

  end

  describe '#current_count' do

    before :each do
      allow(Redis).to receive(:new).and_return(redis)
      @mock_subject = subject.new({})
    end

    it 'should return the current hit count of the key passed' do
      hit_count = rand(10 ** 3) + 1
      expect(redis).to receive(:hget).with(key, 'rate_count').and_return(hit_count)
      expect(@mock_subject.current_count(key)).to eq(hit_count)
    end
  end

  describe '#next_in' do

    before :each do
      allow(Redis).to receive(:new).and_return(redis)
      @mock_subject = subject.new({})
    end

    it 'should return 0 if limit is not breached' do
      expect(@mock_subject).to receive(:current_count).and_return(10)
      expect(@mock_subject.next_in(key, 11, rand(10 ** 2)+1)).to eq(0)
    end

    it 'should return the time remaining if limit is breached' do
      expect(@mock_subject).to receive(:current_count).and_return(10)

      time_now = DateTime.parse('2018-07-01 04:05:23')
      time_start = DateTime.parse('2018-07-01 04:04:53')
      Timecop.freeze(time_now)
      mock_start_time(redis, time_start.to_time.to_i * 1000)
      expect(@mock_subject.next_in(key, 8, 35)).to eq(5)
    end

  end

end