class Crawler
  include Mongoid::Document
  include Mongoid::Timestamps

  has_one :source_website

  field :name, :type => String
  field :url_where_fetch_starts, :type => String
  field :url_being_fetched, :type => String
  field :last_fetched_on, :type => DateTime
  field :last_fetched_item_url, :type => String

  field :max_pages_per_fetch, :type => Integer
  field :max_items_per_fetch, :type => Integer
  field :status, :type => String
  STATUS_BEING_FETCHED = "being fetched"

  def get_entries(opt = {})
    option = { :target_url => url_where_fetch_starts,
      :css => source_website.items_list_css}.merge(opt)
    return get_doc(option[:target_url]).css(option[:css])
  end
  private
  def get_doc(target_url = url_where_fetch_starts)
    logger.info "in source_website.rb, opening url: #{target_url}"
    options = {:headers => {"User-Agent" => Settings.crawler.user_agent}}
    html = MockBrowser.get(target_url, options)
    return Nokogiri::HTML(html)
  end
end
