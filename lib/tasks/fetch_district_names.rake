require 'open-uri'


desc "fetch district names"
task :fetch_name do
  base_url = "http://bj.58.com/xiaoqu/wangjing/?page="
  page_range = (1..11)
  result = []
  page_range.each do |index|
    target_url = "#{base_url}#{index}"
    puts "opening : #{target_url}"
    doc = Nokogiri::HTML(open(target_url))
    doc.css("a.t").each do |a_link|
      name = a_link["href"]
      title = a_link["title"]
      puts "#{name},#{title}"
      result << "#{name},#{title}"
    end
  end
  Crawling.create(:result => result)
end
