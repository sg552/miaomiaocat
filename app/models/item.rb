class Item
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content, :type => String
  field :published_at, :type => DateTime
  field :original_url, :type => String
  field :price, :type => String
  belongs_to :source_website

  def self.create_by_html(html_content, source_website)
    published_at  = html_content.css(source_website.item_published_at_css).text
    link = html_content.css(source_website.item_detail_page_url_css)
    price = html_content.css(source_website.price_css).text
    Item.create(:content => html_content.content,
      :published_at => (published_at == "今天" ? Date.today : published_at),
      :original_url => link.attribute("href"),
      :source_website => source_website,
      :price => price
    )
  end
end
