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
      lambda { @crawler.fetch_items}.should raise_error
    end
    it "basic : items_list_css should be true" do
      @crawler.get_entries.size.should == MAX_RECORD_IN_ONE_PAGE
    end
    it "basic : should perform fetch" do
      @crawler.fetch_items
      Item.all.size.should == MAX_RECORD_IN_ONE_PAGE
    end
    it "basic: once fetched, its last_fetched_item_url and last_fetched_on should exist" do
      Rails.logger.info " test last_fetched_item_url:"
      @crawler.fetch_items
      @crawler.last_fetched_item_url.should_not be_nil
      @crawler.last_fetched_on.should_not be_nil
    end

    it "for a source_website which state is : RUNNING, should not start a new fetch" do
      @crawler.update_attribute(:status, Crawler::RUNNING)
      lambda { @crawler.fetch_items}.should raise_error
    end

    it "for a fetch, should keep the orders of the items. " do
    end
  end
  describe "advanced fetch: for a single page(no pagination)" do
    before do
      @crawler.update_attribute :max_pages_per_fetch, 1
    end
    it "consider the max_items_per_fetch in 1 page" do
      max_items_per_fetch = 8
      @crawler.update_attribute :max_items_per_fetch, max_items_per_fetch
      @crawler.fetch_items
      Item.all.size.should <= max_items_per_fetch
    end

    it "consider the last_fetched_item_url" do
      total_items_count = @crawler.get_entries.size
      last_fetched_item_url = Item.get_original_url(@crawler.get_entries[-3], @source_website)
      @source_website.update_attribute :last_fetched_item_url, last_fetched_item_url
      @crawler.fetch_items
      Item.all.size.should == total_items_count - 3
    end
  end
  describe "advanced fetch: across pagination" do
    before do
      @source_website.update_attribute(:next_page_css, ".pager .next")
    end
    it "should get_next_page_url for valid url " do
      # let's start with the 2nd page
      doc = @crawler.send(:get_doc, @source_website.url_where_fetch_starts)
      page_2_url = @crawler.get_next_page_url(doc)
      doc = @crawler.send(:get_doc, page_2_url)
      page_3_url = @crawler.get_next_page_url(doc)
      page_3_url.should_not be_nil
    end
    it "should return nil if no next_page_url found " do
      doc = @crawler.send :get_doc, 'file://spec/fixtures/page_without_next_page_link.html'
      @crawler.get_next_page_url(doc).should == nil
    end

    it "consider the max_pages_per_fetch" do
      max_pages_per_fetch = 3
      @source_website.update_attribute(:max_pages_per_fetch , max_pages_per_fetch)
      @crawler.fetch_items(:enable_max_pages_per_fetch => true)
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
      doc = @crawler.send :get_doc, @source_website.url_where_fetch_starts
      next_page_url = @crawler.get_next_page_url(doc)
      last_fetched_item = @crawler.get_entries(:target_url => next_page_url)[-4]
      last_fetched_item_url = Item.get_original_url(last_fetched_item, @source_website)
      @source_website.update_attribute(:last_fetched_item_url, last_fetched_item_url)
      @source_website.update_attribute(:max_pages_per_fetch, 3)
      @crawler.fetch_items(:enable_last_fetched_item_url => true, :enable_max_pages_per_fetch => true)
      Item.all.size.should < 2 * MAX_RECORD_IN_ONE_PAGE
    end

    it "should consider the max_items_per_fetch, e.g. max_records_in_a_test_page is #{MAX_RECORD_IN_ONE_PAGE}, and let's set the
      max_items_per_fetch = 15  ( in page2), then the fetch should stop after fetch 50th item " do
      max_items_per_fetch = 30
      @crawler.update_attribute :max_items_per_fetch, max_items_per_fetch
      @crawler.fetch_items
      Item.all.size.should == max_items_per_fetch
    end
  end
  describe "advanced fetch: for the websites with invalid items( top items, ads )" do
    before do
      @source_website.update_attributes(
        :url_where_fetch_starts => "file://spec/fixtures/page1_with_invalid_link.html",
        :next_page_css => nil)
    end
    it "should save them if invalid_item_detail_url_pattern was NOT set" do
      @crawler.fetch_items
      Item.all.size.should == @crawler.get_entries.size
    end
    it "should not save them if invalid_item_detail_url_pattern was set" do
      @source_website.update_attributes(:invalid_item_detail_url_pattern => "/common/cpcredirect.php?")
      @crawler.fetch_items
      Item.all.size.should < @crawler.get_entries.size
    end
    it "should not save them if invalid_item_css_patterns given, as single one" do
      css = ".ico.ding_"
      @source_website.update_attributes(
        :url_where_fetch_starts => "file://spec/fixtures/page1_with_top_items.html",
        :invalid_item_css_patterns => css,
        :next_page_css => nil)
      css1_elements_count = @crawler.get_entries(:css => css)
      css1_elements_count.size.should > 0
      @crawler.fetch_items
      Item.all.size.should == @crawler.get_entries.size - css1_elements_count.size
    end
    it "should not save them if invalid_item_css_patterns given, as single one" do
      css1 = ".ico.ding_"
      css2 = ".ico.ding"
      @source_website.update_attributes(
        :url_where_fetch_starts => "file://spec/fixtures/page1_with_top_items.html",
        :invalid_item_css_patterns => [css1, css2].join(SourceWebsite::INVALID_CSS_SEPARATOR),
        :next_page_css => nil)
      css1_elements_count = @crawler.get_entries(:css => css1).size
      css1_elements_count.should > 0
      css2_elements_count = @crawler.get_entries(:css => css2).size
      css2_elements_count.should > 0
      @crawler.fetch_items
      Item.all.size.should == @crawler.get_entries.size - css1_elements_count - css2_elements_count
    end
  end
  it "should get_entries " do
    @source_website.update_attribute :next_page_css, nil
    @source_website.update_attribute :url_where_fetch_starts, "file://spec/fixtures/page1_with_top_items.html"
    @crawler.get_entries.size.should > 0
    @crawler.get_entries(:css => ".ico.ding_").size.should > 0
  end
  describe "private methods" do
    it "should get_doc" do
      @crawler.send(:get_doc).should_not be_nil
      lambda { @crawler.send :get_doc, "invalid address" }.should raise_error
    end
    it "should get_base_domain_name_of_current_page" do
      base_domain_name = "http://bj.58.com"
      @source_website.update_attribute(:url_where_fetch_starts, base_domain_name + "/zufang?ooxxooxx")
      @crawler.send(:get_base_domain_name_of_current_page).should == base_domain_name
    end
  end
  it "the saved items should keep the order from the page where they come ,e.g.:
    original_page:
      1. item1  (latest)
      2. item2
      3. item3  (oldest record)
    saved items in local db should be ( default order ):
      1. item3  (saved first)
      2. item2  (saved second)
      3. item1  (saved third)
      " do
    @source_website.update_attributes(:next_page_css => nil, :url_where_fetch_starts =>
      "file://spec/fixtures/page1_with_top_items.html")
    original_item_urls= @crawler.get_entries.collect { | raw_item|
      Item.get_original_url(raw_item, @source_website)
    }
    @crawler.fetch_items(:enable_max_items_per_fetch => false)
    saved_item_urls = Item.all.collect { | saved_item | saved_item.original_url }
    original_item_urls.should == saved_item_urls.reverse
  end

  it "for the invalid_item_list_css? , should be nil, or incorrect css" do
    @source_website.update_attributes(:items_list_css => nil)
    @crawler.send(:invalid_item_list_css?).should == true
    @source_website.update_attributes(:items_list_css => "some invalid css")
    @crawler.send(:invalid_item_list_css?).should == true
    @source_website.update_attributes(:items_list_css => "#infolist tr[logr]",
      :url_where_fetch_starts => "file://spec/fixtures/page1_with_top_items.html")
    @crawler.send(:invalid_item_list_css?).should == false
    @source_website.update_attributes(:items_list_css => "#infolist tr[logr]",
      :url_where_fetch_starts => "file://spec/fixtures/page1_with_invalid_items_only.html")
    @crawler.send(:invalid_item_list_css?).should == false
  end
  it "when setting default_count_of_last_fetched_urls = 3,
    should save last_fetched_item_url from a single page, where:
    - url1 (item1)
    - url2 (item2)
    - url3 (item3)
    then saved last_fetched_item_url should be:
    - url1
    - url2
    - url3 " do
    @source_website.update_attributes(:next_page_css => nil, :url_where_fetch_starts =>
      "file://spec/fixtures/page1_with_top_items.html")
    Settings.crawler.stub(:default_count_of_last_fetched_urls){ 3 }
    @crawler.fetch_items
    @crawler.last_fetched_item_url.gsub("file://spec", "").should ==
      ["item1_url", "item2_url", "item3_url"].join(Crawler::LAST_N_URL_SEPARATOR)
  end
  it "should save last_fetched_item_url by order. e.g. :
    before a fetch, the original last_fetched_item_url is: ( the order shown on the page)
    - url_a1
    - url_a2
    - url_a3
    - url_a4
    - url_a5
    after a fetch which fechted:
    - item1_url
    - item2_url
    - item3_url
    then, the updated last_fetched_item_url should be:
    - item1_url
    - item2_url
    - item3_url
    - url_a1
    - url_a2" do
    SourceWebsite::DEFAULT_COUNT_OF_LAST_FETCHED_URLS = 5
    @source_website.update_attributes(:next_page_css => nil,
      :url_where_fetch_starts => "file://spec/fixtures/page1_with_top_items.html")
    @crawler.update_attributes( :last_fetched_item_url => ["url_a1", "url_a2", "url_a3","url_a4","url_a5"].join(Crawler::LAST_N_URL_SEPARATOR))
    Settings.crawler.stub(:default_count_of_last_fetched_urls){ 5 }
    @crawler.fetch_items
    @crawler.last_fetched_item_url.gsub("file://spec", "").should ==
      ["item1_url", "item2_url", "item3_url", "url_a1", "url_a2"].join(Crawler::LAST_N_URL_SEPARATOR)
  end
end
