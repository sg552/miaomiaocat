class SourceWebsite
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, :type => String
  field :url, :type => String
  field :url_where_fetch_starts, :type => String
  field :url_being_fetched, :type => String
  field :last_fetched_on, :type => DateTime
  field :first_fetched_on, :type => DateTime
  field :first_fetched_item_url, :type => String
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
  alias_method :url_where_next_fetch_stops, :last_fetched_item_url

  has_many :items
  def fetch_items(options ={})
    @items_to_create = []
    @items_count_of_this_fetch = 0
    @pages_count_for_this_fetch = 1
    url_being_fetched = url_where_fetch_starts
    catch(:stop_the_entire_fetch) do
      loop do
        logger.debug "saving page: #{@pages_count_for_this_fetch}"
        next_page_url = get_next_page_url(url_being_fetched)
        save_items_for_current_url_that_being_fetched(url_being_fetched, options, @items_to_create)
        url_being_fetched = next_page_url
        @pages_count_for_this_fetch += 1
        if should_stop_reading_for_the_next_page?(next_page_url, options)
          logger.info "stops the loop because of: should_stop_reading_for_the_next_page?: true"
          break
        end
      end
    end
    @items_to_create.reverse.each { |item| item.save! }
    logger.info "== a fetch is done, items_to_create: #{@items_to_create.size} saved"
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
    logger.info "now fetching: #{self.name}"
    if self.status == STATUS_BEING_FETCHED
      warning = "the source_website #{self.name} is being fetched... please stop it if you want another fetch"
      logger.info warning
      raise warning
    end
    update_attribute(:status, STATUS_BEING_FETCHED)
    begin
      original_fetch_items(options)
    rescue Exception => e
      puts "exception: #{e}, more details, please check the log"
      logger.error e
      logger.error e.backtrace.join("\n")
    ensure
      update_attribute(:status, nil)
      save_last_fetched_info(self.first_fetched_item_url)
    end
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
      logger.info "-- now stop_the_entire_fetch_if_possible,
        items_count_of_this_fetch: #{items_count_of_this_fetch},
        last_fetched_item_url reached? #{original_url == source_website_object.last_fetched_item_url}"
      throw :stop_the_entire_fetch
    end
  end

  def should_stop_reading_for_the_next_page?(next_page_url, options)
    result = next_page_url.blank? ||
      (options[:enable_max_pages_per_fetch] == true && @pages_count_for_this_fetch > max_pages_per_fetch)
    if result
      logger.debug "enable_max_items_per_fetch: #{options[:enable_max_pages_per_fetch]}"
      logger.debug "next_page_url :#{next_page_url}, (should not be blank)"
      logger.debug "@pages_count_for_this_fetch: #{@pages_count_for_this_fetch}"
      logger.debug "max_pages_per_fetch: #{max_pages_per_fetch}"
    end
    return result
  end
  def save_items_for_current_url_that_being_fetched(current_page_url, options, items_to_create)
    items = get_items_list(current_page_url)
    items.each do | raw_item |
      stop_the_entire_fetch_if_possible(options, self, Item.get_original_url(raw_item, self), items)
      items_to_create << Item.create_by_html(raw_item, self)
      save_first_fetched_info(items_to_create.last.try(:original_url)) if @items_count_of_this_fetch == 0
      @items_count_of_this_fetch += 1
    end
  end
  def get_base_domain_name_of_current_page
    require 'uri'
    temp = URI.parse(url_where_fetch_starts)
    "#{temp.scheme}://#{temp.host}"
  end
  def get_doc(target_url = url_where_fetch_starts)
    logger.info "in source_website.rb, opening url: #{target_url}"
    options = {:headers => {"User-Agent" => Settings.crawler.user_agent}}
    html = MockBrowser.get(target_url, options).body
    next_page_url = Nokogiri::HTML(html).css("#PageControl1_hlk_next")
    logger.debug("next_page_url: #{next_page_url}")
    return Nokogiri::HTML(html)
  end
  def save_first_fetched_info(original_url)
    logger.debug "saving first_fetched_item_url: #{original_url}"
    update_attributes!(:first_fetched_item_url => original_url, :first_fetched_on => Time.now)
  end
  def save_last_fetched_info(original_url)
    logger.debug "saving last_fetched_item_url: #{original_url}"
    update_attributes!(:last_fetched_item_url => original_url, :last_fetched_on => Time.now)
  end
end
