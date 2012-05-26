class SourceWebsite
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, :type => String
  field :url, :type => String
  field :url_where_fetch_starts, :type => String
  field :url_being_fetched, :type => String
  field :last_fetched_on, :type => DateTime
  field :last_fetched_item_url, :type => String
  field :items_list_css, :type => String
  field :item_detail_page_url_css, :type => String
  field :sample_items_list_content, :type => String
  field :sample_item_content, :type => String
  field :max_pages_per_fetch, :type => Integer
  field :max_items_per_fetch, :type => Integer
  field :item_published_at_css, :type => String
  field :price_css, :type => String
  field :next_page_css, :type => String
  field :previous_page_css, :type => String
  field :status, :type => String
  STATUS_BEING_FETCHED = "being fetched"

  has_many :items
  def fetch_items(options ={})
    @items_count_of_this_fetch = 0
    @pages_count_for_this_fetch = 1
    url_being_fetched = url_where_fetch_starts
    catch(:stop_the_entire_fetch) do
      loop do
        next_page_url = get_next_page_url(url_being_fetched)
        save_items_for_current_url_that_being_fetched(url_being_fetched, options)
        url_being_fetched = next_page_url
        @pages_count_for_this_fetch += 1
        if should_stop_reading_for_the_next_page?(next_page_url, options)
          save_last_fetched_info(Item.last.original_url)
          break
        end
      end
    end
  end

  # ... a test for "around alias"
  alias_method  :original_fetch_items, :fetch_items

  # This is the core method for fetching items
  #
  # ==== Examples
  #
  # Examples please refer to the specs.
  #
  # ==== Options
  #
  # * <tt>:enable_max_items_per_fetch</tt> -  true/false , default is false.
  # * <tt>:enable_last_fetched_item_url</tt> - true/false, default is false.
  # * <tt>:enable_max_pages_per_fetch</tt> - true/false, default is false.
  def fetch_items(options = {})
    if self.status == STATUS_BEING_FETCHED
      raise "the source_website #{self.name} is being fetched... please stop it if you want another fetch"
    end
    update_attribute(:status, STATUS_BEING_FETCHED)
    original_fetch_items(options)
    update_attribute(:status, nil)
  end

  def get_items_list(target_url = url_where_fetch_starts)
    return get_doc(target_url).css(items_list_css)
  end

  # dynamically define methods:
  # get_next_page_url
  # get_previous_page_url
  ["next", "previous"].each do |some|
    define_method :"get_#{some}_page_url" do |current_page_url|
      target_element = get_doc(current_page_url).css(send(:"#{some}_page_css"))
      return nil if target_element.blank?
      href = target_element.attribute("href").to_s
      return href.start_with?("http") ? href : get_base_domain_name_of_current_page + href
    end
  end

  private
  def stop_the_entire_fetch_if_possible(options, source_website_object, original_url, items)
    items_count_of_this_fetch = source_website_object.instance_variable_get(:@items_count_of_this_fetch)
    if (options[:enable_max_items_per_fetch] == true &&
        items_count_of_this_fetch == source_website_object.max_items_per_fetch.to_i ) ||
        (options[:enable_last_fetched_item_url] == true && original_url == source_website_object.last_fetched_item_url)
      save_last_fetched_info(original_url)
      throw :stop_the_entire_fetch
    end
  end

  def should_stop_reading_for_the_next_page?(next_page_url, options)
    return next_page_url.blank? ||
      (options[:enable_max_pages_per_fetch] == true && @pages_count_for_this_fetch > max_pages_per_fetch)
  end
  def save_items_for_current_url_that_being_fetched(current_page_url, options)
    items = get_items_list(current_page_url)
    items.each do | raw_item |
      stop_the_entire_fetch_if_possible(options, self, Item.get_original_url(raw_item, self), items)
      Item.create_by_html(raw_item, self)
      @items_count_of_this_fetch += 1
    end
  end
  def get_base_domain_name_of_current_page
    require 'uri'
    temp = URI.parse(url_where_fetch_starts)
    "#{temp.scheme}://#{temp.host}"
  end
  def get_doc(target_url = url_where_fetch_starts)
    # TODO use httparty instead
    require 'open-uri'
    return Nokogiri::HTML(open(target_url))
  end
  def save_last_fetched_info(original_url)
    update_attributes!(:last_fetched_item_url => original_url, :last_fetched_on => Time.now)
  end
end
