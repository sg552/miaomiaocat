FactoryGirl.define do
  factory :source_website do
    name "58 the same city- wangjing"
    url "http://www.58.com"
    url_where_fetch_starts "http://sh.58.com/zufang"
    items_list_css "#infolist tr[logr]"
    item_detail_page_url_css ".t a[target='_blank']"
    price_css ".tc:nth-last-child(3)"
    item_published_at_css ".tc:nth-last-child(1)"
    max_pages_per_fetch 10
    max_items_per_fetch 1000
    next_page_css ".pager .next"
    previous_page_css ".pager .prv"
  end
  factory :website_with_invalid_items do
    name "Ganji"
    url_where_fetch_starts "http://bj.ganji.com/fang1/"
    items_list_css "dl.list_noimg"
    item_detail_page_url_css "a.list_title"
    price_css ".price"
  end
end
