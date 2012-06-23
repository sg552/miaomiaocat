desc "write index"
   class Article
      include Mongoid::Document
      field :title, :type => String
      field :content, :type => String

      include Tire::Model::Search
      include Tire::Model::Callbacks

      # These Mongo guys sure do get funky with their IDs in +serializable_hash+, let's fix it.
      #
      def to_indexed_json
        self.as_json
      end

    end


task :write_item => :environment do
    puts "begins.."
    Article.create :title => 'I Love ElasticSearch'

    s = Article.tire.search 'love'
puts "done, s: #{s.inspect}"
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
