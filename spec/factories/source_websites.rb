# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :source_website do
    name "58 in the same city"
    url "www.58.com"
    #identifier "integer"
    last_visited_on "2012-05-16"
    last_fetched_at_id "888"
  end
end
