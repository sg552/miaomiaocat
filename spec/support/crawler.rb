class Crawler
  def get_next_page_url(nokogiri_doc)
    target_element = nokogiri_doc.css(source_website.next_page_css)
    return nil if target_element.blank?
    href = target_element.attribute("href").to_s
    return href.start_with?("file://") ? href : "file://spec/fixtures/#{href}"
  end
end
