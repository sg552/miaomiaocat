require 'spec_helper'

#Tire.index 'articles' do
#  delete
#  create
#  store :title => "one", :tags => ['ruby']
#  store :title => "two", :tags => ['ruby', 'python']
#  store :title => "three", :tags => ['java']
#  store :title => "four", :tags => ['c++']
#  refresh
#end
    #articles = [
    #  { :id => '1', :type => 'article', :title => 'one',   :tags => ['ruby']           },
    #  { :id => '2', :type => 'article', :title => 'two',   :tags => ['ruby', 'python'] },
    #  { :id => '3', :type => 'article', :title => 'three', :tags => ['java']           },
    #  { :id => '4', :type => 'article', :title => 'four',  :tags => ['ruby', 'php']    }
    #]

    #Tire.index 'articles' do
    #  import articles do |documents|
    #    documents.each { |document| document[:title].capitalize! }
    #  end
    #  refresh
    #end

describe Item do
  before do
    articles = [
      { :id => '1', :type => 'article', :title => 'one',   :tags => ['ruby']           },
      { :id => '2', :type => 'article', :title => 'two',   :tags => ['ruby', 'python'] },
      { :id => '3', :type => 'article', :title => 'three', :tags => ['java']           },
      { :id => '4', :type => 'article', :title => 'four',  :tags => ['ruby', 'php']    }
    ]

    Tire.index 'articles' do
      import articles do |documents|
        documents.each { |document| document[:title].capitalize! }
      end
      refresh
    end
  end
  after do
    Tire.index 'articles' do
      delete
    end
  end

  it "should create" do
    index = Tire::Index.new "wokao"
    index.delete
    index.create
    index.store :title => "wo le ge qu~"
    index.refresh
  end
  it "should query" do
    s = Tire.search 'articles' do
      query do
        string 'title:*o*'
      end
      filter :term, :tags => ['ruby']
      sort { by :title , 'desc'}
      facet 'global-tags', :global => true do
        terms :tags
      end
      facet 'current-tags' do
        terms :tags
      end
    end
    s.results.each do |document|
      puts "* #{document.title} [tags: #{document.tags.join(",")}]"
    end
    s.results.facets['global-tags']['terms'].each do |f|
      puts "#{f['term'].ljust(10)} #{f['count']}"
    end
    s.results.facets['current-tags']['terms'].each do |f|
      puts "#{f['term'].ljust(10)} #{f['count']}"
    end
  end
  it "should query using a hash (like json)" do
    puts "=== now query using a hash"
    s = Tire.search 'articles', :query => { :prefix => { :title => 'f' } }
    puts "s.to_curl: #{s.to_curl}"
    puts "s.to_json: #{s.to_json}"
    puts "result: "
    s.results.each do |document|
      puts "** #{document.title} [tags: #{document.tags.join(',')}]"
    end
  end
end
