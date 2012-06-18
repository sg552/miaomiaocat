task :fetch_items => :environment do
  SourceWebsite.all.each do |source_website|
    source_website.fetch_items
  end
end
