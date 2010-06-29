require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "RRDSimple" do

  before(:each) do
    redis.flushdb
    @r = RRDSimple.new(:buckets => 60, :step => 60, :db => redis) # 60 minutes
  end

  it "should return the proper key for last_epoch" do
    @r.last_epoch_key('k').should == 'k:epoch'
  end
end

