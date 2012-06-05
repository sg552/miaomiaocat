
task :fetch_items do
  SourceWebsite.all.each do |source_website|
    source_website.fetch_items(:enable_max_pages_per_fetch => true,
      :enable_max_items_per_fetch => true, :enable_last_fetched_item_url => true)
  end
end
