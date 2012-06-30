class Item
  include Mongoid::Document
  include Mongoid::Timestamps
  include Tire::Model::Search
  include Tire::Model::Callbacks
  field :content, :type => String
  field :original_url, :type => String
  belongs_to :source_website
  validates_uniqueness_of :original_url, :message => "original_url duplicated!"

  def self.new_by_html(html_content, source_website)
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
    return url.start_with?("http") ? url : source_website.crawler.send(:get_base_domain_name_of_current_page) + url
  end
  # see : http://stackoverflow.com/questions/5123993/json-encoding-wrongly-escaped-rails-3-ruby-1-9-2
  # see : http://stackoverflow.com/a/6744852/445908
  alias_method :original_to_indexed_json, :to_indexed_json
  def to_indexed_json
    original_to_indexed_json.gsub!(/\\u([0-9a-z]{4})/) {|s| [$1.to_i(16)].pack("U")}
  end

  ## for tire's import
  #def self.paginate args
  #  self.page args
  #end
end
