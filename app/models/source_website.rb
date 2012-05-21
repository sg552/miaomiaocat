class SourceWebsite
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, :type => String
  field :url, :type => String
  field :url_where_fetch_starts, :type => String
  field :last_fetched_on, :type => DateTime
  field :last_fetched_item_url, :type => String
  field :items_list_css, :type => String
  field :item_detail_page_url_css, :type => String
  field :sample_items_list_content, :type => String
  field :sample_item_content, :type => String
  field :max_pages_per_fetch, :type => Integer
  field :max_items_per_fetch, :type => Integer
  field :item_published_at_css, :type => String
  field :price_css, :type => String
  field :next_page_css, :type => String
  field :previous_page_css, :type => String
  has_many :items
  def dig_for_58
    urls = ["http://bj.58.com/zufang/?final=1&key=%E4%B8%9C%E7%9B%B4%E9%97%A8",
      "http://bj.58.com/zufang/?final=1&key=%E6%9C%9B%E4%BA%AC"]
    urls.each do |url|
      doc = Nokogiri::HTML(open(url))
      doc.css("table.tblist tr[logr]").each do | raw_item |
        Item.create_by_html(raw_item, SourceWebsite.where(:name => "58同城").first)
      end
    end
  end
end
