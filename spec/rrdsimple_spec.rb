require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "RRDSimple" do

  let(:rr) { RRDSimple.new(:step => 60, :buckets => 60, :db => redis) }
  let(:jan01) {Time.utc(2010,1,1.0,0)}

  before(:each) { time_travel_to(jan01) }
  before(:each) { redis.flushdb }

  it "should return the proper key for last_epoch" do
    rr.last_epoch_key('k').should == 'k:epoch'
  end

  it "should return zero as last_epoch for an empty rrdsimple" do
    rr.last_epoch('k').should == 0
  end

  it "should not exist in redis last epoch key related to an empty rrdsimple" do
    redis.exists("k:epoch").should be_false
  end

  it "should not exist in redis any bucket key related to an empty rrdsimple" do
    60.times do |i|
      redis.exists("k:{i}").should be_false
    end
  end

  it "should increment buckets within correct epoch" do
    rr.epoch("k").should match(/k:0/)
    rr.incr("k").should == 1
    rr.incr("k", 2).should == 3
    rr.incr("k").should == 4
    # The bucket should have the counter
    redis.get('k:0').to_i.should == 4
    # The epoch should be consistent
    redis.get('k:epoch').to_i.should == jan01.to_i / 60

    jump 60 # jump one minute
    rr.incr("k").should == 1
    rr.incr("k").should == 2

    # The bucket should have the counter
    redis.get('k:0').to_i.should == 4
    redis.get('k:1').to_i.should == 2
    # The epoch should be consistent
    redis.get('k:epoch').to_i.should == (jan01 + 60).to_i / 60


    jump 120 # jump two minute
    rr.incr("k").should == 1
    rr.incr("k").should == 2

    # The bucket should have the counter
    redis.get('k:0').to_i.should == 4
    redis.get('k:1').to_i.should == 2
    redis.exists('k:2').should be_false
    redis.get('k:3').to_i.should == 2
    # The epoch should be consistent
    redis.get('k:epoch').to_i.should == (jan01 + 60 + 120).to_i / 60

    rr.clear('k')
    redis.exists("k:epoch").should be_false
    60.times do |i|
      redis.exists("k:{i}").should be_false
    end
  end
end

