require 'spec/spec_helper'

describe Crawler do
  before do
    crawler = create(:crawler)
    #crawler.source_website = create(:source_website)
  end
  it "should run a fetch as thread" do
    #SourceWebsite.first.fectch_items_as_thread(:sleep_time => 10)
  end
end
