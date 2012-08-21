FactoryGirl.define do
  sequence(:random_url) { |n|  "http://ooxx.#{n}.com" }
  factory :item do
    content "<div>title: ... price ...</div>"
    original_url {FactoryGirl.generate(:random_url)}
    association :source_website, :factory => :source_website
  end
end
