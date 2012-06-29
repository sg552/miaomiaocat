class Crawler
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_one :source_website

  field :name, :type => String
  field :url_where_fetch_starts, :type => String
  field :url_being_fetched, :type => String
  field :last_fetched_on, :type => DateTime
  field :last_fetched_item_url, :type => String

  field :max_pages_per_fetch, :type => Integer
  field :max_items_per_fetch, :type => Integer
  field :status, :type => String
  STATUS_BEING_FETCHED = "being fetched"

end
