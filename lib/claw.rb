# a crawler, in common meaning.
# however since miaomiaocat is a cat, so name it "Claw", meaning that a cat is fiddling things(infos)
# with the claws and finally fetched the information.
require 'open-uri'
class Claw
  def dig_for_58
    urls = ["http://bj.58.com/zufang/?final=1&key=%E4%B8%9C%E7%9B%B4%E9%97%A8",
      "http://bj.58.com/zufang/?final=1&key=%E6%9C%9B%E4%BA%AC"]
    urls.each do |url|
      doc = Nokogiri::HTML(open(url))
      doc.css("tr.trout").each do | raw_item |
        Item.create_by_html( raw_item)
      end
    end
  end

end