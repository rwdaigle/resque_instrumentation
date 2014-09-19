require 'rubygems'
require 'resque'

$:.unshift(File.expand_path(File.dirname(__FILE__)) + '/../lib')
require 'resque_instrumentation'

class InstrumentedJob
  extend Resque::Plugins::Instrumentation::Job
  @queue = :test

  def self.perform(arg)
  end
end

class InstrumentedFailureJob
  extend Resque::Plugins::Instrumentation::Job
  @queue = :test

  def self.perform(arg)
    raise "I failed. At life."
  end
end
