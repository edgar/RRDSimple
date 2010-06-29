require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "RRDSimple" do

  let(:rr) { RRDSimple.new(:step => 60, :buckets => 60, :db => redis, :debug => true) }
  let(:jan01) {Time.utc(2010,1,1.0,0)}

  before(:each) { time_travel_to(jan01) }
  before(:each) { redis.flushdb }

  it "should return the proper key for last_epoch" do
    rr.last_epoch_key('k').should == 'k:epoch'
  end

  it "should return zero as last_epoch for an empty rrdsimple" do
    rr.last_epoch('k').should == 0
  end

  it "should increment buckets within correct epoch" do
    rr.epoch("k").should match(/k:0/)
    rr.incr("k")
  end
end

