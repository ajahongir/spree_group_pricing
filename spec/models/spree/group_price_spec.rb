require 'spec_helper'

describe Spree::GroupPrice do
  it { should belong_to(:variant) }
  it { should validate_presence_of(:variant) }
  it { should validate_presence_of(:amount) }

  before(:each) do
    @group_price = build :group_price
  end

  it 'should set range based on start and end range fields' do
    @group_price.save
    @group_price.reload
    @group_price.range.should eql('(1..5)')
  end

  it "should not interepret a Ruby range as being opend ended" do
    @group_price.range = "(1..2)"
    @group_price.should_not be_open_ended
  end
  
  it "should properly interpret an open ended range" do
    @group_price.range = "(50+)"
    @group_price.should be_open_ended
  end
  
  describe "valid range format" do
    it "should require the presence of a variant" do
      @group_price.variant = nil
      @group_price.should_not be_valid
    end
    it "should consider a range of (1..2) to be valid" do
      @group_price.range = "(1..2)"
      @group_price.should be_valid
    end
    it "should consider a range of (1...2) to be valid" do
      @group_price.range = "(1...2)"
      @group_price.should be_valid
    end
    it "should consider a range of 1..2 to be valid" do
      @group_price.range = "1..2"
      @group_price.should be_valid
    end
    it "should consider a range of 1...2 to be valid" do
      @group_price.range = "1...2"
      @group_price.should be_valid
    end
    it "should consider a range of (10+) to be valid" do
      @group_price.range = "(10+)"
      @group_price.should be_valid
    end
    it "should consider a range of 10+ to be valid" do
      @group_price.range = "10+"
      @group_price.should be_valid
    end
    it "should not consider a range of 1-2 to valid" do
      @group_price.end_range = nil
      @group_price.start_range = nil
      @group_price.range = "1-2"
      @group_price.should_not be_valid
    end
    it "should not consider a range of 1 to valid" do
      @group_price.end_range = nil
      @group_price.start_range = nil
      @group_price.range = "1"
      @group_price.should_not be_valid
    end
    it "should not consider a range of foo to valid" do
      @group_price.end_range = nil
      @group_price.start_range = nil
      @group_price.range = "foo"
      @group_price.should_not be_valid
    end
  end
  
  describe "include?"  do    
    it "should not match a quantity that fails to fall within the specified range" do
      @group_price.range = "(10..20)"
      @group_price.should_not include(21)
    end
    it "should match a quantity that is within the specified range" do
      @group_price.range = "(10..20)"
      @group_price.should include(12)
    end
    it "should match the upper bound of ranges that include the upper bound" do
      @group_price.range = "(10..20)"
      @group_price.should include(20)
    end
    it "should not match the upper bound for ranges that exclude the upper bound" do
      @group_price.range = "(10...20)"
      @group_price.should_not include(20)
    end
    it "should match a quantity that exceeds the value of an open ended range" do
      @group_price.range = "(50+)"
      @group_price.should include(51)
    end
    it "should match a quantity that equals the value of an open ended range" do
      @group_price.range = "(50+)"
      @group_price.should include(50)
      @group_price.range = "50+"
      @group_price.should include(50)

    end
    it "should not match a quantity that is less then the value of an open ended range" do
      @group_price.range = "(50+)"
      @group_price.should_not include(40)
    end    
  end
end
