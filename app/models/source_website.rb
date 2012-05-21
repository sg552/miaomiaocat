class SourceWebsite
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, :type => String
  field :url, :type => String
  field :last_visited_on, :type => DateTime
  field :last_fetched_at_id, :type => String
  field :last_fetched_item_url, :type => String
  field :information_list_css, :type => String
  field :original_url_css, :type => String
  field :sample_item_content, :type => String
  has_many :items
end
