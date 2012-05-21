# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :source_website do
    name "58 in the same city"
    url "www.58.com"
    #identifier "integer"
    last_visited_on "2012-05-16"
    last_fetched_at_id "888"
    last_fetched_item_url "http://bj.58.com/zufang/?final=1&key=%E4%B8%9C%E7%9B%B4%E9%97%A8"
    #information_list_css "table.tblist"
    #information_list_css ".t a[target='_blank']"
    #published_at_css 'css(".tc").last.content'
  end
end
