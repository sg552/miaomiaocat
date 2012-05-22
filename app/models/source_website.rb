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
  def fetch_items
    # TODO use httparty instead
    require 'open-uri'
    doc = Nokogiri::HTML(open(url_where_fetch_starts))
    doc.css(items_list_css).each { | raw_item | Item.create_by_html(raw_item, self) }
  end

  # ... a test for "around alias"
  alias_method  :original_fetch_items, :fetch_items
  def fetch_items
    update_attribute(:status, STATUS_BEING_FETCHED)
    original_fetch_items
    update_attribute(:status, nil)
  end

end
