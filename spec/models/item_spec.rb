require 'spec_helper'

describe Item do
  before do
    @item = create(:item)
  end
  it "should load factory" do
    @item.source_website.should == SourceWebsite.find(@item.source_website_id)
  end
end
