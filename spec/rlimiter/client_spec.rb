require 'spec_helper'

RSpec.describe Rlimiter::Client do

  describe '#limit' do
    it "shouldn't do anything" do
      expect(Rlimiter::Client.new.limit('test', 2, 20)).to be nil
    end
  end

  describe '#next_in' do
    it "shouldn't do anything" do
      expect(Rlimiter::Client.new.next_in('test', 20)).to be nil
    end
  end

  describe '#current_count' do
    it "shouldn't do anything" do
      expect(Rlimiter::Client.new.current_count('test')).to be nil
    end
  end
end