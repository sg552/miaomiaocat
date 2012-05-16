require 'spec_helper'

describe SourceWebsite do
  before  do
    create(:source_website)
  end
  it "should save" do
    SourceWebsite.all.size.should > 0
  end
end
