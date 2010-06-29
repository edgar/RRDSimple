$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rrdsimple'
require 'spec'
require 'spec/autorun'
require 'delorean'
require 'ruby-debug'

def redis
  @redis ||= Redis.new(:host => 'localhost', :port => 6379, :db => 15 )
end

Spec::Runner.configure do |config|
  config.include Delorean
  config.after :suite do
    redis.flushdb
  end
end

