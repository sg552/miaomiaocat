FactoryGirl.define do
  factory :item do
    content "<div>title: ... price ...</div>"
    original_url "http://bj.58.com/hezu/9795159781508x.shtml"
    association :source_website, :factory => :source_website
  end
end
