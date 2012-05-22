require 'spec_helper'

describe SourceWebsite do
  before  do
    @source_website = create(:source_website)
  end
  it "should save" do
    SourceWebsite.all.size.should > 0
  end

  describe "basic fetch" do
    it "basic : should fetch from remote website" do
      @source_website.fetch_items
      Item.all.size.should > 30
    end
    it "basic: once fetched, its last_fetched_item_url and last_fetched_on should exist" do
      @source_website.update_attributes(:last_fetched_item_url => nil, :last_fetched_on => nil)
      @source_website.fetch_items
      @source_website.last_fetched_item_url.match(/http.*/).should_not be_nil
      @source_website.last_fetched_on.should_not be_nil
    end
    it "for a source_website which state is : STATUS_BEING_FETCHED, should not start a new fetch" do
      @source_website.update_attribute(:status, SourceWebsite::STATUS_BEING_FETCHED)
      lambda { @source_website.fetch_items}.should raise_error
    end
  end

  describe "advanced fetch: for a single page(no pagination)" do
    it "consider the max_items_per_fetch in 1 page" do
      max_items_per_fetch = 12
      @source_website.update_attribute(:max_items_per_fetch, max_items_per_fetch)
      @source_website.fetch_items :enable_max_items_per_fetch => true
      Item.all.size.should <= max_items_per_fetch
    end


    it "consider the last_fetched_item_url" do
      # first of all, get the total items in a page
      @source_website.fetch_items
      total_items_count = Item.all.size
      Item.delete_all

      last_fetched_item_url = Item.get_original_url @source_website.get_items_list[-3], @source_website
      @source_website.update_attribute(:last_fetched_item_url, last_fetched_item_url)
      @source_website.fetch_items :enable_last_fetched_item_url => true
      Item.all.size.should == total_items_count - 3
    end

  end
  describe "advanced fetch: across pagination" do
    it "consider the max_pages_per_fetch" do
      max_records_in_a_page = 37
      max_pages_per_fetch = 3
      @source_website.update_attribute(:max_pages_per_fetch, max_pages_per_fetch)
      @source_website.fetch_items
      (2*max_records_in_a_page .. 3*max_records_in_a_page).include?(Item.all.size).should == true
    end
  end

  it "should get_items_list" do
    @source_website.get_items_list.size.should > 30
  end

end
