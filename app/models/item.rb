class Item
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content, :type => String
  field :published_at, :type => DateTime
  field :original_url, :type => String
  belongs_to :source_website
end
