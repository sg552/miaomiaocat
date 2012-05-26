require 'open-uri'
require 'lib/claw'
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

task :fetch_message do
  html_prefix_content = %Q{
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html"; charset="utf-8">
    <script type="text/javascript" language="javascript" src="jquery.js"></script>
    <script type="text/javascript" language="javascript" src="jquery.dataTables.js"></script>
    <script type="text/javascript" charset="utf-8">
    $(document).ready(function() {
    $('table').dataTable();
    } );
    </script>
</head>
<body>
<table>
<thead>
<tr>
<td class="tdimg">图片？</td>
<td class="tdt" width="400">标题 </td>
<td width="90">户型</td>
<td width="90">面积</td>
<td width="90" class="tdprice">价格</td>
</tr>
</head>
<tbody>
  }
  #landlord_only = true
  landlord_only = false
  file = File.new("district_names.txt")
  url_suffix = landlord_only ? "chuzu/?ib=0" : "chuzu/?ib=1"
  file_name = landlord_only ? "html_landlord.html" : "html_result.html"

  valid_links = []
  while( line = file.gets)
    valid_links << line.match("http.*\/")[0] if line.match("http.*\/")
  end
  valid_links = valid_links.compact
  html_result = []
  valid_links.each do |link|
    # only 1 page considered
    # landlord only.
    target_url = "#{link}chuzu/?ib=0&r=&mp="
    # both agent and landlord
    target_url = "#{link}#{url_suffix}"
    puts "opening : #{target_url}"
    doc = Nokogiri::HTML(open(target_url))

    doc.css("tr.trout").each do |message|
      html_result << message
    end
  end
  File.open(file_name, "w") do |f|
    f.write(html_prefix_content)
    f.write(html_result)
    f.write("</tbody></table></body></html>")
  end
  puts "done"
end

task :dig_for_58 do
  source_website = SourceWebsite.where(:name => /58/).first
  source_website.fetch_items(:enable_max_pages_per_fetch => true,
    :enable_max_items_per_fetch => true)
end
