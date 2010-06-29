require 'rubygems'
gem 'redis', '>= 2.0.3'
require 'redis'

class RRDSimple
  def initialize(opts)
    @buckets = opts[:buckets]
    @step = opts[:step]
    @debug = opts[:debug] || false
    @db = opts[:db] || Redis.new
  end

  def time_epoch
    (Time.now.utc.to_i / @step) % @buckets
  end

  def epochs_ago(set, num)
    b = time_epoch-num
    b = (b < 0) ? @buckets + b : b
    "#{set}:#{b}"
  end

  def buckets(set)
    a = []
    i = 0
    while (i < @buckets) do
      a.push epochs_ago(set, v)
    end
    a
  end

  def last_epoch_key(set)
    "#{set}:epoch"
  end

  def last_epoch(set)
    @db.get(last_epoch_key(set)).to_i
  end

  def epoch(set)
    current_e = time_epoch
    last_e = last_epoch(set)
    if current_e != last_e
      time_now = Time.now.utc.to_i / @step
      [(time_now - last_e).abs, @buckets].min.times do |n|
        clear_bucket(epochs_ago(set, n))
      end
      @db.set(last_epoch_key(set), time_now)
    end
    "#{set}:#{current_e}"
  end

  def incr(set, val=1)
    debug [:incr, epoch(set), val]
    @db.incrby(epoch(set), val).to_i
  end

  def set(set, key, val)
    debug [:set, epoch(set), val, key]
    @db.set(epoch(set), val, key)
  end

  def clear(set)
    @db.del(last_epoch_key(set))
    buckets(set){|b| clear_bucket(b)}
  end

  protected

    def clear_bucket(b)
      debug [:clearing_epoch, b]
      @db.del(b)
    end

    def debug(msg); puts msg if @debug; end

end

