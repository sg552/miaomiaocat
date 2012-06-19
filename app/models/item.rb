class Item
  include Mongoid::Document
  include Mongoid::Timestamps
  include Tire::Model::Search
  include Tire::Model::Callbacks
  field :content, :type => String
  field :original_url, :type => String
  belongs_to :source_website

  def self.create_by_html(html_content, source_website)
    original_url = get_original_url(html_content, source_website)
    item = Item.new(:content => html_content.content,
      :original_url => original_url,
      :source_website => source_website
    )
    logger.debug "newed item: original_url: #{original_url}"
    return item
  end
  def self.get_original_url(html_content, source_website)
    url = html_content.css(source_website.item_detail_page_url_css).attribute("href").to_s
    return url.start_with?("http") ? url : source_website.send(:get_base_domain_name_of_current_page) + url
  end
end
