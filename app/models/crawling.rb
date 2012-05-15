class Crawling
  include Mongoid::Document
  field :url, :type => String
  field :key_word, :type => String
  field :result, :type => String
end
