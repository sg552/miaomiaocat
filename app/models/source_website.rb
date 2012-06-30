class SourceWebsite
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :crawler

  field :name, :type => String
  field :url_where_fetch_starts, :type => String

  field :items_list_css, :type => String
  field :item_detail_page_url_css, :type => String
  field :next_page_css, :type => String

  field :invalid_item_detail_url_pattern, :type => String
  field :invalid_item_css_patterns, :type => String

  has_many :items
end
