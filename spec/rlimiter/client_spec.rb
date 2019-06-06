require 'spec_helper'

RSpec.describe Rlimiter::Client do

  subject {Rlimiter::Client.new}

  describe '#limit' do
    it "shouldn't do anything" do
      expect(subject.limit('test', 2, 20)).to be nil
    end
  end

  describe '#next_in' do
    it "shouldn't do anything" do
      expect(subject.next_in('test', 20)).to be nil
    end
  end

  describe '#current_count' do
    it "shouldn't do anything" do
      expect(subject.current_count('test')).to be nil
    end
  end

  describe '#clear' do
    it "shouldn't do anything" do
      expect(subject.clear('test')).to be nil
    end
  end

end