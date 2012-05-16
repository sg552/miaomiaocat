class SourceWebsite
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, :type => String
  field :url, :type => String
  field :last_visited_on, :type => DateTime
  field :last_fetched_at_id, :type => String
  has_many :items
end
