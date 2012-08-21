class Location
  include Mongoid::Document
  include Mongoid::Timestamps
  include Tire::Model::Search
  include Tire::Model::Callbacks
  field :name, :type => String

  # this mimic method (macro) generates two methods:
  # Location#parent_location
  # Location#child_locations
  recursively_embeds_many
  has_many :items
end
