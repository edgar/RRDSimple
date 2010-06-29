require 'rubygems'
gem 'redis', '>= 2.0.3'
require 'redis'

class RRDSimple
  def initialize(opts)
    @buckets = opts[:buckets]
    @step = opts[:step]
    @debug = opts[:debug] || false
    @db = opts[:db] || Redis.new
    @current = nil
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
    now = set + ":" + current_e.to_s
    if now != @current and current_e != last_e
      debug [:new_epoch, current_e]
      [(Time.now.to_i / @step - last_e).abs, @buckets].min.times do |n|
        clear_bucket(epochs_ago(set, n))
      end
      @current = now
      @db.set(last_epoch_key(set), Time.now.to_i / @step)
    end
    @current
  end

  def incr(set, key, val=1)
    debug [:incr, epoch(set), val, key]
    @db.incr(epoch(set), val, key).to_i
  end

  def set(set, key, val)
    debug [:set, epoch(set), val, key]
    @db.set(epoch(set), val, key)
  end

  def clear(set)
    buckets(set){|b| clear_bucket(b)}
  end

  protected

    def clear_bucket(b)
      debug [:clearing_epoch, b]
      @db.del(b)
    end

    def debug(msg); p msg if @debug; end

end

