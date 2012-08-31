require 'spec_helper'

describe Location do

  it "should belong to a parent location" do
    parent = create(:location, :name => 'parent')
    child = parent.child_locations.build(:name => 'child')
    child.parent_location.should == parent
    parent.child_locations.should == [child]
    # another child
    child2 = parent.child_locations.build(:name => 'child2')
    child2.parent_location.should == parent
    parent.child_locations.should == [child,child2]
  end

  it "should have many items" do
    location = create(:location)
    a = FactoryGirl.create(:item, :location_id => location.id)
    b = FactoryGirl.create(:item, :location_id => location.id)
    c = FactoryGirl.create(:item, :location_id => location.id)
    location.items.should == [a,b,c]
    a.location.should == location
  end

  it "should define as: district, business_circle, residential " do
    chaoyang = District.new(:name => "Chaoyang")
    chaoyang._type.should == District.to_s
  end

  it "should fetch locations" do
    url = "spec/fixtures/district_names_page.html"
    Location.fetch_all(url)
    Location.all.size.should > 200
  end
end
