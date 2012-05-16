# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :item do
    content "<div>title: ... price ...</div>"
    original_url "http://bj.58.com/hezu/9795159781508x.shtml"
    published_at "2012-05-12 12:00:00"
    association :source_website, :factory => :source_website
  end
end
