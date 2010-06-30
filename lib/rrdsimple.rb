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

  def current_epoch
    Time.now.utc.to_i / @step
  end

  def current_bucket
    current_epoch % @buckets
  end

  def last_epoch_key(k)
    "#{k}:epoch"
  end

  def last_epoch(k)
    @db.get(last_epoch_key(k)).to_i
  end

  def set_last_epoch(k,v = Time.now.utc.to_i)
    @db.set(last_epoch_key(k), v)
  end

  def last_bucket(set)
    last_epoch(set) % @buckets
  end

  def epochs_ago(k, num)
    b = current_bucket-num
    b = (b < 0) ? @buckets + b : b
    "#{k}:#{b}"
  end

  def buckets(k)
    a = []
    i = 0
    while (i < @buckets) do
      a.push epochs_ago(k, i)
      i += 1
    end
    a
  end

  def epoch(k)
    current_e = current_epoch
    last_e = last_epoch(k)
    if current_e != last_e
      [(current_e - last_e).abs, @buckets].min.times do |n|
        clear_bucket(epochs_ago(k, n))
      end
      set_last_epoch(k, current_e)
    end
    "#{k}:#{current_bucket}"
  end

  def incr(k, val=1)
    debug [:incr, epoch(k), val]
    @db.incrby(epoch(k), val).to_i
  end

  def set(k, val)
    debug [:set, epoch(k), val]
    @db.set(epoch(k), val)
  end

  def clear(k)
    @db.del(last_epoch_key(k))
    buckets(k){|b| clear_bucket(b)}
  end

  protected

    def clear_bucket(b)
      debug [:clearing_epoch, b]
      @db.del(b)
    end

    def debug(msg); puts msg if @debug; end

end

