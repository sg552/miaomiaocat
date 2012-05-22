require 'spec_helper'

describe SourceWebsite do
  before  do
    @source_website = create(:source_website)
  end
  it "should save" do
    SourceWebsite.all.size.should > 0
  end

  it "should fetch from remote website" do
    @source_website.fetch_items
    Item.all.size.should > 30
  end
end
