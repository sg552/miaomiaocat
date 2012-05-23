class SourceWebsite
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, :type => String
  field :url, :type => String
  field :url_where_fetch_starts, :type => String
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
    index = 0
    items = get_items_list
    items.each do | raw_item |
      original_url = Item.get_original_url(raw_item, self)
      break if options[:enable_max_items_per_fetch] == true && index == max_items_per_fetch.to_i
      break if options[:enable_last_fetched_item_url] == true && original_url == last_fetched_item_url
      Item.create_by_html(raw_item, self)
      index += 1
      save_last_fetched_info(original_url) if index == items.size
    end
  end

  # ... a test for "around alias"
  alias_method  :original_fetch_items, :fetch_items
  def fetch_items(options = {})
    if self.status == STATUS_BEING_FETCHED
      raise "the source_website #{self.name} is being fetched... please stop it if you want another fetch"
    end
    update_attribute(:status, STATUS_BEING_FETCHED)
    original_fetch_items(options)
    update_attribute(:status, nil)
  end

  def get_items_list
    doc = get_doc
    return doc.css(items_list_css)
  end

  # dynamically define methods:
  # get_next_page_url
  # get_previous_page_url
  ["next", "previous"].each do |some|
    define_method :"get_#{some}_page_url" do
      href = get_doc.css(send(:"#{some}_page_css")).attribute("href").to_s
      return href.start_with?("http") ? href : get_base_domain_name_of_current_page + href
    end
  end

  private
  def get_base_domain_name_of_current_page
    require 'uri'
    temp = URI.parse(url_where_fetch_starts)
    "#{temp.scheme}://#{temp.host}"
  end
  def get_doc
    # TODO use httparty instead
    require 'open-uri'
    return Nokogiri::HTML(open(url_where_fetch_starts))
  end
  def save_last_fetched_info(original_url)
    update_attributes!(:last_fetched_item_url => original_url, :last_fetched_on => Time.now)
  end
end
