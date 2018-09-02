require 'rlimiter/version'
require_files = %w[/rlimiter/*.rb]
require_files.each do |file|
  Dir.glob(File.dirname(File.absolute_path(__FILE__)) + file, &method(:require))
end

module Rlimiter
  class << self
    attr_reader :client
  end
end
