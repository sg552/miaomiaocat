class Article
  #include Mongoid::Document
  #field :title, :type => String
  #field :content, :type => String


  attr_reader :title, :tags
  def initialize(attributes = {})
    @attributes = attributes
    @attributes.each_pair { |name, value| instance_variable_set :"@#{name}", value}
  end

  #include Tire::Model::Search
  #include Tire::Model::Callbacks

  # These Mongo guys sure do get funky with their IDs in +serializable_hash+, let's fix it.
  #
  def to_indexed_json
    #result= self.as_json
    #puts "to_indexed_json: #{result.inspect}"
    #return result
    result = @attributes.as_json
    puts "json: #{result.inspect}"
    return result
  end
  def type
    'article'
  end
end

desc "write index"
task :write_item => :environment do
  puts "begins.."
  Tire.index 'wokaoles' do
    article = Article.new :title => 'wokaole .....', :tag => 'dang~'
    store article
    refresh
  end
  puts "done"

  Tire.index 'apples' do
    delete
    create
    store :title => "red one", :tags => [:red, :soft]
    store :title => 'green one', :tags => [:green, :not_soft]
    store :title => 'green two', :tags => [:green, :not_soft], :type => 'green apple'
  end
  #s = Article.tire.search 'love'
  #puts "done, s: #{s.inspect}"
  #Item.import
  #Item.index.import(Item.all)
  #Item.all.each do |item|
  #  puts "item: #{item.id}"
  #  Item.create item.as_json
  #end
  #Item.create :content => "blablabla2", :original_url => '3333'

  #s = Item.tire.search 'la'
  #s.each do |result|
  #  puts "content: #{result.content}"
  #end

end

#
#
#sg552@siwei-moto:~/workspace/miaomiaocat$ curl localhost:9200/items/item/_mapping -d '
#{
#  "item" : {
#    "_all" : {
#            "indexAnalyzer" : "mmseg",
#            "searchAnalyzer": "mmseg",
#            "term_vector": "no",
#            "store": "false"
#        },
#    "properties": {
#        "content": {
#                "type": "string",
#                "store": "yes",
#                "term_vector": "with_positions_offsets",
#                "indexAnalyzer": "mmseg",
#                "searchAnalyzer": "mmseg",
#                "include_in_all": "true",
#                "boost": 8
#            }
#        }
#    }
#}'
#
Tire.index "items" do
  create :mappings => {
    :items => {
      :properties => {
        :content => {:type => "string", :analyzer => "mmseg" }
      }
    }
  }
end
