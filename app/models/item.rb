class Item
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content, :type => String
  field :published_at, :type => DateTime
  field :original_url, :type => String
  belongs_to :source_website
  def self.create_by_html(html_content)
    published_at  = html_content.css(".tc").last.content
    # css(".t a") also works
    link = html_content.css(".t a[target='_blank']").first
    Item.create(:content => html_content.content,
      :published_at => published_at == "今天" ? Date.today : published_at,
      :original_url => link.attribute("href")
    )
  end
end
