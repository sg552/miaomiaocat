task :fetch_items => :environment do
  threads = []
  SourceWebsite.all.each do |source_website|
    threads << Thread.new {
      source_website.fectch_items_as_thread
    }
  end
  threads.each { |thread| thread.join}
end

task :fetch_items_for_the_first_website => :environment do
  source_website = SourceWebsite.where(:url_where_fetch_starts => "http://bj.58.com/hezu/").to_a.first
  Thread.new {
    source_website.fectch_items_as_thread
  }.join
end
