# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :source_website do
    name "58 the same city- wangjing"
    url "http://www.58.com"
    url_where_fetch_starts "http://bj.58.com/zufang/?final=1&key=%E6%9C%9B%E4%BA%AC"
    items_list_css "table.tblist tr[logr]"
    item_detail_page_url_css ".t a[target='_blank']"
    price_css ".tc:nth-last-child(3)"
    item_published_at_css ".tc:nth-last-child(1)"
    max_pages_per_fetch 10
    max_items_per_fetch 1000
    next_page_css ".pager .next"
    previous_page_css ".pager .prv"
  end
end
