require 'spec_helper'

describe SourceWebsite do
  before  do
    @source_website = create(:source_website)
  end
  it "should save" do
    SourceWebsite.all.size.should > 0
  end

  describe "basic fetch, for a single page" do
    before do
      @source_website.update_attributes(:last_fetched_item_url => nil, :next_page_css => nil)
      Item.delete_all
      Item.all.size.should == 0
    end
    it "basic : should fetch from remote website" do
      @source_website.fetch_items
      Item.all.size.should > 30
    end
    it "basic: once fetched, its last_fetched_item_url and last_fetched_on should exist" do
      Rails.logger.info " test last_fetched_item_url:"
      @source_website.fetch_items
      @source_website.last_fetched_item_url.should_not be_nil
      @source_website.last_fetched_on.should_not be_nil
    end

    it "for a source_website which state is : STATUS_BEING_FETCHED, should not start a new fetch" do
      @source_website.update_attribute(:status, SourceWebsite::STATUS_BEING_FETCHED)
      lambda { @source_website.fetch_items}.should raise_error
    end

    it "for a fetch, should keep the orders of the items. " do
    end
  end

  describe "advanced fetch: for a single page(no pagination)" do
    before do
      @source_website.update_attribute(:max_pages_per_fetch, 1)
    end
    it "consider the max_items_per_fetch in 1 page" do
      max_items_per_fetch = 12
      @source_website.update_attribute(:max_items_per_fetch, max_items_per_fetch)
      @source_website.fetch_items :enable_max_items_per_fetch => true, :enable_max_pages_per_fetch => true
      Item.all.size.should <= max_items_per_fetch
    end

    it "consider the last_fetched_item_url" do
      Rails.logger.info "here -A ==="
      total_items_count = @source_website.get_items_list.size
      last_fetched_item_url = Item.get_original_url(@source_website.get_items_list[-3], @source_website)
      @source_website.update_attribute(:last_fetched_item_url, last_fetched_item_url)
      @source_website.fetch_items :enable_last_fetched_item_url => true, :enable_max_pages_per_fetch => true
      Item.all.size.should == total_items_count - 3
    end
  end
  describe "advanced fetch: across pagination" do
    before do
      @source_website.update_attribute(:next_page_css, ".pager .next")
      @source_website.update_attribute(:previous_page_css, ".pager .prv")
    end
    it "should get_next_page_url and get_previous_page_url for valid url " do

      # let's start with the 2nd page
      page_2_url = @source_website.get_next_page_url(@source_website.url_where_fetch_starts)
      page_3_url = @source_website.get_next_page_url(page_2_url)
      page_3_url.should_not be_nil

      # then should get 2nd page as the 'previous page'
      @source_website.get_previous_page_url(page_3_url).should == page_2_url
    end
    it "should return nil if no next_page_url/previous_page_url found " do
      @source_website.get_next_page_url('file://spec/fixtures/page_without_next_page_link.html').should == nil
    end

    it "consider the max_pages_per_fetch" do
      max_records_in_a_page = 37
      max_pages_per_fetch = 3
      @source_website.update_attribute(:max_pages_per_fetch , max_pages_per_fetch)
      @source_website.fetch_items(:enable_max_pages_per_fetch => true)
      (2*max_records_in_a_page .. 3*max_records_in_a_page).include?(Item.all.size).should == true
    end

    it "should_stop_reading_for_the_next_page if next_page_url is blank, or reached max_pages_per_fetch" do
      @source_website.send(:"should_stop_reading_for_the_next_page?", nil, {}).should == true
      max_pages_per_fetch = 3
      option = {:enable_max_pages_per_fetch => true}

      @source_website.update_attribute(:max_pages_per_fetch, max_pages_per_fetch)
      @source_website.instance_variable_set(:@pages_count_for_this_fetch, max_pages_per_fetch - 1)
      @source_website.send(:"should_stop_reading_for_the_next_page?", "valid_addr", option).should == false
      @source_website.instance_variable_set(:@pages_count_for_this_fetch, max_pages_per_fetch )
      @source_website.send(:"should_stop_reading_for_the_next_page?", "valid_addr", option).should == false
      @source_website.instance_variable_set(:@pages_count_for_this_fetch, max_pages_per_fetch + 1)
      @source_website.send(:"should_stop_reading_for_the_next_page?", "valid_addr", option).should == true
    end
    it "should consider the last_fetched_item_url, assume the last_fetched_item_url is on 2nd page,
        the last but 8 ( -9 in Chinese ^_^ )" do
      next_page_url = @source_website.get_next_page_url(@source_website.url_where_fetch_starts)
      last_fetched_item = @source_website.get_items_list(next_page_url)[-9]
      last_fetched_item_url = Item.get_original_url(last_fetched_item, @source_website)
      @source_website.update_attribute(:last_fetched_item_url, last_fetched_item_url)
      @source_website.update_attribute(:max_pages_per_fetch, 3)
      @source_website.fetch_items(:enable_last_fetched_item_url => true, :enable_max_pages_per_fetch => true)
      max_records_in_a_page = 37
      Item.all.size.should < 2 * max_records_in_a_page
    end

    it "should consider the max_items_per_fetch, e.g. max_records_in_a_page is 37, and let's set the
      max_items_per_fetch = 50  ( in page2), then the fetch should stop after fetch 50th item " do
      max_items_per_fetch = 50
      @source_website.update_attribute(:max_items_per_fetch, max_items_per_fetch)
      @source_website.fetch_items :enable_max_items_per_fetch => true
      Item.all.size.should == max_items_per_fetch
    end
  end

  it "should get_items_list" do
    @source_website.get_items_list.size.should > 30
  end
  describe "private methods" do
    it "should get_doc" do
      @source_website.send(:get_doc).should_not be_nil
      lambda { @source_website.send :get_doc, "invalid address" }.should raise_error
    end
    it "should save_last_fetched_info, e.g.  saved items:
        - item1,  url_1
        - item2,  url_2
        - item3,  url_3
      , the save_last_fetched_info shoud == 'url_3#{SourceWebsite::LAST_N_URL_SEPARATOR}url_2'" do
      (1..10).each { |i| create(:item, :original_url => "url_#{i}") }
      @source_website.update_attributes(:save_last_fetched_info => nil, :last_fetched_on => nil)
      url = "this is the url of the last item"
      @source_website.send(:save_last_fetched_info, 3)
      @source_website.last_fetched_item_url.should ==
        ["url_10", "url_9", "url_8"].join(SourceWebsite::LAST_N_URL_SEPARATOR)
      @source_website.last_fetched_on.should_not be_nil
    end
    it "should get_base_domain_name_of_current_page" do
      base_domain_name = "http://bj.58.com"
      @source_website.update_attribute(:url_where_fetch_starts, base_domain_name + "/zufang?ooxxooxx")
      @source_website.send(:get_base_domain_name_of_current_page).should == base_domain_name
    end
  end

  describe "for the websites with invalid items" do
    before do
      # TODO why can't I just use:  create(:website_with_invalid_items) ?
      @source_website.update_attributes(
        :url_where_fetch_starts => "file://spec/fixtures/page1_with_invalid_link.html",
        :next_page_css => nil)
    end
    it "should save them if invalid_item_detail_url_pattern was NOT set" do
      @source_website.fetch_items
      Item.all.size.should == @source_website.get_items_list.size
    end
    it "should not save them if invalid_item_detail_url_pattern was set" do
      @source_website.update_attributes(:invalid_item_detail_url_pattern => "/common/cpcredirect.php?")
      @source_website.fetch_items
      Item.all.size.should < @source_website.get_items_list.size
    end
    it "should not save them if invalid_item_css_patterns given, as single one" do
      css = ".ico.ding_"
      @source_website = create(:source_website)
      @source_website.update_attributes(
        :url_where_fetch_starts => "file://spec/fixtures/page1_with_top_items.html",
        :invalid_item_css_patterns => css,
        :next_page_css => nil)
      css1_elements_count = @source_website.get_entries(:css => css)
      css1_elements_count.size.should > 0
      @source_website.fetch_items
      Item.all.size.should == @source_website.get_items_list.size - css1_elements_count.size
    end
    it "should not save them if invalid_item_css_patterns given, as single one" do
      css1 = ".ico.ding_"
      css2 = ".ico.ding"
      @source_website = create(:source_website)
      @source_website.update_attributes(
        :url_where_fetch_starts => "file://spec/fixtures/page1_with_top_items.html",
        :invalid_item_css_patterns => [css1, css2].join(SourceWebsite::INVALID_CSS_SEPARATOR),
        :next_page_css => nil)
      css1_elements_count = @source_website.get_entries(:css => css1).size
      css1_elements_count.should > 0
      css2_elements_count = @source_website.get_entries(:css => css2).size
      css2_elements_count.should > 0
      @source_website.fetch_items
      Item.all.size.should == @source_website.get_items_list.size - css1_elements_count - css2_elements_count
    end
  end
  it "should get_entries " do
    @source_website.get_entries.size.should > 0
    @source_website.get_entries(:css => ".ico.ding_").size.should > 0
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
    original_item_urls= @source_website.get_entries.collect { | raw_item|
      Item.get_original_url(raw_item, @source_website)
    }
    @source_website.fetch_items(:enable_max_items_per_fetch => false)
    saved_item_urls = Item.all.collect { | saved_item | saved_item.original_url }
    original_item_urls.should == saved_item_urls.reverse
  end
end
