require 'spec_helper'

RSpec.describe Rlimiter do

  subject {Rlimiter}
  let(:subject_obj) {subject.class.new}
  let(:redis_client) {double(Rlimiter::RedisClient)}
  let(:mock_params) {{test: 'val'}}

  def mock_with_redis(subject, redis_client)
    params = {client: 'redis', host: 'localhost', port: 6379}
    expect(Rlimiter::RedisClient).to receive(:new).with(params).and_return(redis_client)
    subject.init(params)
  end

  it 'has a version number' do
    expect(subject::VERSION).not_to be nil
  end

  describe '#init' do

    it "should initialize with 'redis' client when passed" do
      mock_with_redis(subject, redis_client)
      expect(subject.instance_variable_get(:@client)).to eq(redis_client)
    end

    it 'should return InvalidClientError if an invalid client is passed' do
      expect {subject.init(client: 'invalid_client')}.to raise_error(Rlimiter::InvalidClientError,
                                                                     'Valid clients are redis')
    end

  end

  describe '#limit' do
    it 'should call the client\'s :limit method with same params' do
      mock_with_redis(subject, redis_client)
      expect(redis_client).to receive(:limit).with(mock_params)
      subject.limit(mock_params)
    end
  end

  describe '#next_in' do
    it 'should call the client\'s :next_in method with same params' do
      mock_with_redis(subject, redis_client)
      expect(redis_client).to receive(:next_in).with(mock_params)
      subject.next_in(mock_params)
    end
  end

  describe '#current_count' do
    it 'should call the client\'s :current_count method with same params' do
      mock_with_redis(subject, redis_client)
      expect(redis_client).to receive(:current_count).with(mock_params)
      subject.current_count(mock_params)
    end
  end
end
