class Location
  include Mongoid::Document
  include Mongoid::Timestamps
  include Tire::Model::Search
  include Tire::Model::Callbacks
  field :name, :type => String
  field :original_url, :type => String

  # this mimic method (macro) generates two methods:
  # Location#parent_location
  # Location#child_locations
  recursively_embeds_many
  has_many :items

  require 'open-uri'
  def self.fetch_all(url)
    options = {}
    options[:district_css]=".subinfoin dl:first dd:first a"
    options[:business_circle_css] = "ul.classul li a"
    doc = Nokogiri::HTML(open(url))
    puts "doc: #{doc.css(options[:district_css])}"

    doc.css(options[:district_css]).each do |a_link|
      original_url = a_link["href"]
      name = a_link.text
      District.create(:name => name, :original_url => original_url)
      puts "#{name},#{original_url}"
    end
    raise "from here, get all the business circles "

    #doc.css(options[:business_circle_css]).each do |a_link|
    #  name = a_link["href"]
    #  title = a_link["title"]
    #  puts "#{name},#{title}"
    #end
  end
end

# TODO are they needed?
# 朝阳区
class District < Location; end
# 商业圈，例如： 望京
class BusinessCircle< Location; end
# 某个住宅小区，例如： 南湖西里
class Residential< Location; end
