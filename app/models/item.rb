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
    item = Item.new(:content => html_content.content,
      :published_at => (published_at == "今天" ? Date.today : published_at),
      :original_url => original_url,
      :source_website => source_website,
      :price => price
    )
    logger.debug "newed item: original_url: #{original_url}"
    return item
  end
  def self.get_original_url(html_content, source_website)
    url = html_content.css(source_website.item_detail_page_url_css).attribute("href").to_s
    return url.start_with?("http") ? url : source_website.send(:get_base_domain_name_of_current_page) + url
  end
end
