class SourceWebsite
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :crawler

  field :name, :type => String
  field :url, :type => String

  field :url_where_fetch_starts, :type => String
  field :last_fetched_item_url, :type => String

  field :items_list_css, :type => String
  field :item_detail_page_url_css, :type => String
  field :next_page_css, :type => String

  field :invalid_item_detail_url_pattern, :type => String
  field :invalid_item_css_patterns, :type => String
  STATUS_BEING_FETCHED = 'being fetched'
  INVALID_CSS_SEPARATOR = ';'
  LAST_N_URL_SEPARATOR = '###'
  alias_method :url_where_next_fetch_stops, :last_fetched_item_url

  has_many :items

  def fetch_items(options ={})
    @items_to_create = []
    @items_count_of_this_fetch = 0
    @pages_count_for_this_fetch = 1
    next_page_url = ""
    url_being_fetched = url_where_fetch_starts
    catch(:stop_the_entire_fetch) do
      loop do
        logger.debug "saving page: #{@pages_count_for_this_fetch}"
        nokogiri_doc= crawler.get_doc(url_being_fetched)
        save_items_for_current_url_that_being_fetched(nokogiri_doc, options, @items_to_create)
        next_page_url = crawler.get_next_page_url nokogiri_doc
        url_being_fetched = next_page_url
        @pages_count_for_this_fetch += 1
        if should_stop_reading_for_the_next_page?(next_page_url, options)
          logger.info "-- (name: #{name}) should stop:because of: reached max pages?: true"
          break
        end
      end
    end
    @items_to_create.reverse.each { |item| item.save! }
    logger.info "== a fetch(#{name}) is done, items_to_create: #{@items_to_create.size} saved"
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
  # * <tt>:enable_max_items_per_fetch</tt> -  true/false , default is true.
  # * <tt>:enable_last_fetched_item_url</tt> - true/false, default is true.
  # * <tt>:enable_max_pages_per_fetch</tt> - true/false, default is true.
  def fetch_items(options = {})
    options = options.reverse_merge(:enable_max_items_per_fetch => true,
      :enable_last_fetched_item_url => true ,
      :enable_max_pages_per_fetch => true)

    logger.info "now fetching: #{self.name}"
    if crawler.status == STATUS_BEING_FETCHED
      warning = "the source_website #{self.name} is being fetched... please stop it if you want another fetch"
      logger.info warning
      raise warning
    end
    if invalid_item_list_css?
      warning = "the source_website #{self.name} seems has no entries, is the css: /#{items_list_css}/ correct? "
      logger.info warning
      raise warning
    end
    crawler.update_attribute(:status, STATUS_BEING_FETCHED)
    logger.debug "-- last_fetched_item_url: "
    logger.debug "-- \n #{last_fetched_item_url.split(LAST_N_URL_SEPARATOR).join("\n")}" unless last_fetched_item_url.blank?
    begin
      original_fetch_items(options)
    rescue Exception => e
      puts "exception: #{e}, more details, please check the log"
      logger.error e
      logger.error e.backtrace.join("\n")
    ensure
      crawler.update_attribute(:status, nil)
      save_last_fetched_info
    end
  end

  def fectch_items_as_thread(options = {})
    options = options.reverse_merge(:sleep_time => Settings.crawler.default_sleep_time)
    logger.info "-- now starts fetching: #{self.name}"
    loop do
      fetch_items(options)
      logger.info "-- now sleep #{options[:sleep_time]}s for the next fetch."
      sleep options[:sleep_time]
    end
  end

  private
  def invalid_item_list_css?
    return items_list_css.blank? || crawler.get_entries.blank?
  end
  def stop_the_entire_fetch_if_possible(options, source_website_object, original_url, items)
    is_to_stop = false
    items_count_of_this_fetch = source_website_object.instance_variable_get(:@items_count_of_this_fetch)
    if options[:enable_max_items_per_fetch] == true &&
        items_count_of_this_fetch == source_website_object.crawler.max_items_per_fetch.to_i
      is_to_stop = true
      logger.info "--(name:#{name}) stop: reached max_items_per_fetch. ( items_count_of_this_fetch: #{items_count_of_this_fetch}"
    end
    if options[:enable_last_fetched_item_url] == true &&
          source_website_object.last_fetched_item_url.try(:include?, original_url)
      logger.info "--(name:#{name}) stop: last_fetched_item_url reached: #{original_url} "
      is_to_stop = true
    end
    throw :stop_the_entire_fetch if is_to_stop
  end

  def should_stop_reading_for_the_next_page?(next_page_url, options)
    result = next_page_url.blank? ||
      (options[:enable_max_pages_per_fetch] == true &&
      @pages_count_for_this_fetch > crawler.max_pages_per_fetch)
    if result
      logger.info "--(name: #{name}) should stop: reach max_pages_per_fetch: #{crawler.max_pages_per_fetch}"
      logger.debug "next_page_url :#{next_page_url}, (should not be blank)"
      logger.debug "@pages_count_for_this_fetch: #{@pages_count_for_this_fetch}"
    end
    return result
  end
  def save_items_for_current_url_that_being_fetched(doc, options, items_to_create)
    items = doc.css(items_list_css)
    items.each do | raw_item |
      item_original_url = Item.get_original_url(raw_item, self)
      if !self.invalid_item_detail_url_pattern.blank? &&
        item_original_url =~ Regexp.new(self.invalid_item_detail_url_pattern)
        logger.debug "found invalid item, skipped: #{item_original_url}"
        next
      end
      unless self.invalid_item_css_patterns.blank?
        temp_should_next_item = false
        self.invalid_item_css_patterns.split(INVALID_CSS_SEPARATOR).each do |invalid_css|
          unless raw_item.css(invalid_css).blank?
            logger.debug "found invalid css, skipped: #{invalid_css}, url: #{ item_original_url}"
            temp_should_next_item = true
            # break the current loop (invalid item css loop)
            break
          end
        end
        # next the loop: scanning items.
        next if temp_should_next_item
      end
      stop_the_entire_fetch_if_possible(options, self, Item.get_original_url(raw_item, self), items)
      items_to_create << Item.new_by_html(raw_item, self)
      @items_count_of_this_fetch += 1
    end
  end
  def save_last_fetched_info(default = Settings.crawler.default_count_of_last_fetched_urls)
    return nil if @items_to_create.blank?
    logger.debug "now save_last_fetched_info ... @items_to_create.size: #{@items_to_create.size}"
    original_last_fetch_item_urls = last_fetched_item_url.try(:split, LAST_N_URL_SEPARATOR) || []
    last_fetched_item_url = (@items_to_create.collect{|item| item.original_url} +
      original_last_fetch_item_urls )[0, default].join(LAST_N_URL_SEPARATOR)
    update_attributes!(:last_fetched_item_url => last_fetched_item_url, :last_fetched_on => Time.now)
  end
end
