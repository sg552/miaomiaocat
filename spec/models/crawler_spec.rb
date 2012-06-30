require 'spec/spec_helper'

describe Crawler do
  MAX_RECORD_IN_ONE_PAGE = 10
  before do
    @crawler = create(:crawler)
    @source_website = @crawler.source_website
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
      @source_website.get_entries.size.should == MAX_RECORD_IN_ONE_PAGE
    end
    it "basic : should perform fetch" do
      @source_website.fetch_items
      Item.all.size.should == MAX_RECORD_IN_ONE_PAGE
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
  describe "advanced fetch: for a single page(no pagination)" do
    before do
      @source_website.update_attribute :max_pages_per_fetch, 1
    end
    it "consider the max_items_per_fetch in 1 page" do
      max_items_per_fetch = 12
      @crawler.update_attribute :max_items_per_fetch, max_items_per_fetch
      @source_website.fetch_items
      Item.all.size.should <= max_items_per_fetch
    end

    it "consider the last_fetched_item_url" do
      total_items_count = @source_website.get_entries.size
      last_fetched_item_url = Item.get_original_url(@source_website.get_entries[-3], @source_website)
      @source_website.update_attribute :last_fetched_item_url, last_fetched_item_url
      @source_website.fetch_items
      Item.all.size.should == total_items_count - 3
    end
  end
  describe "advanced fetch: across pagination" do
    before do
      @source_website.update_attribute(:next_page_css, ".pager .next")
    end
    it "should get_next_page_url for valid url " do

      # let's start with the 2nd page
      doc = @source_website.send(:get_doc, @source_website.url_where_fetch_starts)
      page_2_url = @source_website.get_next_page_url(doc)
      doc = @source_website.send(:get_doc, page_2_url)
      page_3_url = @source_website.get_next_page_url(doc)
      page_3_url.should_not be_nil

    end
    it "should return nil if no next_page_url found " do
      doc = @source_website.send :get_doc, 'file://spec/fixtures/page_without_next_page_link.html'
      @source_website.get_next_page_url(doc).should == nil
    end

    it "consider the max_pages_per_fetch" do
      max_pages_per_fetch = 3
      @source_website.update_attribute(:max_pages_per_fetch , max_pages_per_fetch)
      @source_website.fetch_items(:enable_max_pages_per_fetch => true)
      (2*MAX_RECORD_IN_ONE_PAGE.. 3*MAX_RECORD_IN_ONE_PAGE).include?(Item.all.size).should == true
    end

    it "should_stop_reading_for_the_next_page if next_page_url is blank,
      or reached max_pages_per_fetch, e.g. max_pages_per_fetch = 3, should 'stop reading next page' at page == 3 " do
      # should stop if next_page_url is blank
      @source_website.send(:"should_stop_reading_for_the_next_page?", nil, {}).should == true

      max_pages_per_fetch = 2
      option = {:enable_max_pages_per_fetch => true}

      @crawler.update_attribute(:max_pages_per_fetch, max_pages_per_fetch)

      @source_website.instance_variable_set(:@pages_count_for_this_fetch, max_pages_per_fetch - 1)
      @source_website.send(:"should_stop_reading_for_the_next_page?", "valid_next_page_url", option).should == false

      @source_website.instance_variable_set(:@pages_count_for_this_fetch, max_pages_per_fetch )
      @source_website.send(:"should_stop_reading_for_the_next_page?", "valid_next_page_url", option).should == false

      @source_website.instance_variable_set(:@pages_count_for_this_fetch, max_pages_per_fetch + 1)
      @source_website.send(:"should_stop_reading_for_the_next_page?", "valid_next_page_url", option).should == true
    end
    it "should consider the last_fetched_item_url, assume the last_fetched_item_url is on 2nd page,
        the last but 3 ( -4 in Chinese ^_^ )" do
      doc = @source_website.send :get_doc, @source_website.url_where_fetch_starts
      next_page_url = @source_website.get_next_page_url(doc)
      last_fetched_item = @source_website.get_entries(:target_url => next_page_url)[-4]
      last_fetched_item_url = Item.get_original_url(last_fetched_item, @source_website)
      @source_website.update_attribute(:last_fetched_item_url, last_fetched_item_url)
      @source_website.update_attribute(:max_pages_per_fetch, 3)
      @source_website.fetch_items(:enable_last_fetched_item_url => true, :enable_max_pages_per_fetch => true)
      Item.all.size.should < 2 * MAX_RECORD_IN_ONE_PAGE
    end

    it "should consider the max_items_per_fetch, e.g. max_records_in_a_test_page is #{MAX_RECORD_IN_ONE_PAGE}, and let's set the
      max_items_per_fetch = 15  ( in page2), then the fetch should stop after fetch 50th item " do
      max_items_per_fetch = 30
      @crawler.update_attribute :max_items_per_fetch, max_items_per_fetch
      @source_website.fetch_items
      Item.all.size.should == max_items_per_fetch
    end
  end
end
