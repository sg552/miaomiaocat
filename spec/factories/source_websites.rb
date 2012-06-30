FactoryGirl.define do
  factory :source_website do
    name "mocked site"
    url_where_fetch_starts "file://spec/fixtures/page1_the_simplest.html"
    items_list_css "#infolist tr[logr]"
    item_detail_page_url_css ".t a[target='_blank']"
    next_page_css ".pager .next"
  end
end
