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
    rr.last_epoch('k').should == jan01.to_i / 60
    v = rr.values('k')
    v.size.should == 1
    v[0][:value].should == 4
    # The following to assertion are equivalent
    v[0][:epoch].should == jan01.to_i / 60
    Time.at(v[0][:epoch]*60).should == jan01

    jump 60 # jump one minute
    rr.incr("k").should == 1
    rr.incr("k").should == 2

    # The bucket should have the counter
    redis.get('k:0').to_i.should == 4
    redis.get('k:1').to_i.should == 2
    # The epoch should be consistent
    rr.last_epoch('k').should == (jan01 + 60).to_i / 60

    # values
    v = rr.values('k')
    v.size.should == 2

    v[0][:value].should == 2
    # The following to assertion are equivalent
    v[0][:epoch].should == (jan01 + 60).to_i / 60
    Time.at(v[0][:epoch]*60).should == jan01 + 60

    v[1][:value].should == 4
    # The following to assertion are equivalent
    v[1][:epoch].should == jan01.to_i / 60
    Time.at(v[1][:epoch]*60).utc.should == jan01


    jump 60*2 # jump two minute
    rr.incr("k").should == 1
    rr.incr("k").should == 2
    rr.incr("k").should == 3

    # The bucket should have the counter
    redis.get('k:0').to_i.should == 4
    redis.get('k:1').to_i.should == 2
    redis.exists('k:2').should be_false
    redis.get('k:3').to_i.should == 3
    # The epoch should be consistent
    rr.last_epoch('k').should == (jan01 + 60 + 120).to_i / 60

    # values
    v = rr.values('k')
    v.size.should == 3

    v[0][:value].should == 3
    # The following to assertion are equivalent
    v[0][:epoch].should == (jan01 + 60 + 60*2).to_i / 60
    Time.at(v[0][:epoch]*60).should == jan01 + 60 + 60*2

    v[1][:value].should == 2
    # The following to assertion are equivalent
    v[1][:epoch].should == (jan01 + 60).to_i / 60
    Time.at(v[1][:epoch]*60).should == jan01 + 60

    v[2][:value].should == 4
    # The following to assertion are equivalent
    v[2][:epoch].should == jan01.to_i / 60
    Time.at(v[2][:epoch]*60).utc.should == jan01

    jump 60*30 # jump 30 minutes

    rr.incr('k').should == 1
    # The bucket should have the counter
    redis.get('k:0').to_i.should == 4
    redis.get('k:1').to_i.should == 2
    redis.exists('k:2').should be_false
    redis.get('k:3').to_i.should == 3
    (4..32).each do |i|
      redis.exists("k:#{i}").should be_false
    end
    redis.get('k:33').to_i.should == 1

    # The epoch should be consistent
    rr.last_epoch('k').should == (jan01 + 60 + 60*2 + 60*30).to_i / 60

    # values
    v = rr.values('k')
    v.size.should == 4

    v[0][:value].should == 1
    # The following to assertion are equivalent
    v[0][:epoch].should == (jan01 + 60 + 60*2 + 60*30).to_i / 60
    Time.at(v[0][:epoch]*60).should == jan01 + 60 + 60*2 + 60*30

    v[1][:value].should == 3
    # The following to assertion are equivalent
    v[1][:epoch].should == (jan01 + 60 + 60*2).to_i / 60
    Time.at(v[1][:epoch]*60).should == jan01 + 60 + 60*2

    v[2][:value].should == 2
    # The following to assertion are equivalent
    v[2][:epoch].should == (jan01 + 60).to_i / 60
    Time.at(v[2][:epoch]*60).should == jan01 + 60

    v[3][:value].should == 4
    # The following to assertion are equivalent
    v[3][:epoch].should == jan01.to_i / 60
    Time.at(v[3][:epoch]*60).utc.should == jan01

    jump 60*45 # jump 45 minutes
    rr.last_epoch('k').should == (jan01 + 60 + 60*2 + 60*30).to_i / 60

    rr.incr('k').should == 1
    rr.incr('k').should == 2
    rr.incr('k').should == 3
    rr.incr('k').should == 4
    rr.incr('k').should == 5

    # The bucket should have the counter
    (0..17).each do |i|
      redis.exists("k:#{i}").should be_false
    end
    redis.get('k:18').to_i.should == 5
    (19..32).each do |i|
      redis.exists("k:#{i}").should be_false
    end
    redis.get('k:33').to_i.should == 1
    (34..59).each do |i|
      redis.exists("k:#{i}").should be_false
    end

    # values
    v = rr.values('k')
    v.size.should == 2

    v[0][:value].should == 5
    # The following to assertion are equivalent
    v[0][:epoch].should == (jan01 + 60 + 60*2 + 60*30 + 60*45).to_i / 60
    Time.at(v[0][:epoch]*60).should == jan01 + 60 + 60*2 + 60*30 + 60*45

    v[1][:value].should == 1
    # The following to assertion are equivalent
    v[1][:epoch].should == (jan01 + 60 + 60*2 + 60*30).to_i / 60
    Time.at(v[1][:epoch]*60).should == jan01 + 60 + 60*2 + 60*30


    rr.clear('k')
    redis.exists("k:epoch").should be_false
    (0..59).each do |i|
      redis.exists("k:{i}").should be_false
    end
  end
end

