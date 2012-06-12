class Crawler
  include Mongoid::Document
  include Mongoid::Timestamps

  has_one :source_website

  field :url_where_fetch_starts, :type => String
  field :url_being_fetched, :type => String
  field :last_fetched_on, :type => DateTime
  field :first_fetched_on, :type => DateTime
  field :first_fetched_item_url, :type => String
  field :last_fetched_item_url, :type => String

  field :max_pages_per_fetch, :type => Integer
  field :max_items_per_fetch, :type => Integer
  field :item_published_at_css, :type => String
  field :status, :type => String
  STATUS_BEING_FETCHED = "being fetched"
end
