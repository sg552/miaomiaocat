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
    price = html_content.css(source_website.price_css).text
    original_url = get_original_url(html_content, source_website)
    Item.create(:content => html_content.content,
      :published_at => (published_at == "今天" ? Date.today : published_at),
      :original_url => original_url,
      :source_website => source_website,
      :price => price
    )
    logger.debug "saving item: original_url: #{original_url}"
  end
  def self.get_original_url(html_content, source_website)
    html_content.css(source_website.item_detail_page_url_css).attribute("href").to_s
  end
end
