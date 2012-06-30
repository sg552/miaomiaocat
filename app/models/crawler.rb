class Crawler
  include Mongoid::Document
  include Mongoid::Timestamps

  has_one :source_website

  field :name, :type => String
  field :url_being_fetched, :type => String
  field :last_fetched_on, :type => DateTime
  field :last_fetched_item_url, :type => String

  field :max_pages_per_fetch, :type => Integer
  field :max_items_per_fetch, :type => Integer
  field :status, :type => String
  STATUS_BEING_FETCHED = "being fetched"

  def get_entries(opt = {})
    option = { :target_url => source_website.url_where_fetch_starts,
      :css => source_website.items_list_css}.merge(opt)
    return get_doc(option[:target_url]).css(option[:css])
  end
  def get_next_page_url(nokogiri_doc)
    target_element = nokogiri_doc.css(source_website.next_page_css)
    return nil if target_element.blank?
    href = target_element.attribute("href").to_s
    return href.start_with?("http") ? href : get_base_domain_name_of_current_page + href
  end
  private
  def get_doc(target_url = source_website.url_where_fetch_starts)
    logger.info "in source_website.rb, opening url: #{target_url}"
    options = {:headers => {"User-Agent" => Settings.crawler.user_agent}}
    html = MockBrowser.get(target_url, options)
    return Nokogiri::HTML(html)
  end
  def get_base_domain_name_of_current_page
    require 'uri'
    temp = URI.parse(source_website.url_where_fetch_starts)
    "#{temp.scheme}://#{temp.host}"
  end
end
