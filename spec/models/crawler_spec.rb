require 'spec/spec_helper'

describe Crawler do
  before do
    @crawler = create(:crawler)
    @source_website = @crawler.source_website
    @max_records_in_a_test_page = 10
  end
  describe "basic fetch, for a single page" do
    before do
      @source_website.update_attributes :next_page_css => nil
    end
    it "basic( stop strategy): it should stop if the items_list_css is incorrect" do
      @source_website.update_attributes(:items_list_css => nil)
      lambda { @source_website.fetch_items}.should raise_error
    end
    it "basic : items_list_css should be true" do
      @source_website.get_entries.size.should == @max_records_in_a_test_page
    end
    it "basic : should perform fetch" do
      @source_website.fetch_items
      Item.all.size.should == @max_records_in_a_test_page
    end
    it "basic: once fetched, its last_fetched_item_url and last_fetched_on should exist" do
      Rails.logger.info " test last_fetched_item_url:"
      @source_website.fetch_items
      @source_website.last_fetched_item_url.should_not be_nil
      @source_website.last_fetched_on.should_not be_nil
    end

    it "for a source_website which state is : STATUS_BEING_FETCHED, should not start a new fetch" do
      @crawler.update_attribute(:status, SourceWebsite::STATUS_BEING_FETCHED)
      lambda { @source_website.fetch_items}.should raise_error
    end

    it "for a fetch, should keep the orders of the items. " do
    end
  end
end
