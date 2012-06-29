FactoryGirl.define do
  factory :crawler do
    name "crawler of 58.com"
    url_being_fetched "url that is being fetched"
    last_fetched_on "2012-06-29"
    last_fetched_item_url "aaabbbccc"
    max_pages_per_fetch 30
    max_items_per_fetch 10000
    status ""
    #source_website Factory.build(:source_website)
  end
end
