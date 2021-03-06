require 'spec_helper'

describe Item do
  before do
    @item = create(:item)
    @crawler = create(:crawler)
    @source_website = @crawler.source_website
    @original_url = "http://bj.58.com/zufang/9883174197507x.shtml"
    @price = "1800"
    @content = %Q{
<tr logr="p_0_7021042612230" class="                ">
  <td class="t"><a class="t" target="_blank" href="#{@original_url}">无中介费,<b><b>望京</b></b>新城四区次卧低价出租140</a><span class="ico area"><a href="/wangjing/zufang/" class="c_58">望京</a>
    <span class="f12">望京新城四区</span> </span><span class="ico biz">(个人)</span><span class="ico ntu">[1图]</span><span name="zaixian_7021042612230"></span></td>
  <td class="tc"><b class="pri">#{@price}</b></td>
  <td class="tc">3室2厅2卫</td>
  <td class="tc">今天</td>
</tr>
    }
  end
  it "should load factory" do
    @item.source_website.should == SourceWebsite.find(@item.source_website_id)
  end
  it "should get_original_url if original_url starts_with http" do
    # absolute path
    Item.get_original_url(Nokogiri::HTML(@content), @source_website).should == @original_url
    # related path
    related_url = "/some_related_path"
    @content = %Q{
<tr logr="p_0_7021042612230" class="">
  <td class="t"><a class="t" target="_blank" href="#{related_url}">无中介费,<b><b>望京</b></b>新城四区次卧低价出租140</a><span class="ico area"><a href="/wangjing/zufang/" class="c_58">望京</a>
    <span class="f12">望京新城四区</span> </span><span class="ico biz">(个人)</span><span class="ico ntu">[1图]</span><span name="zaixian_7021042612230"></span></td>
  <td class="tc"><b class="pri">33</b></td>
  <td class="tc">3室2厅2卫</td>
  <td class="tc">今天</td>
</tr>
    }
    @source_website.update_attribute :url_where_fetch_starts, "http://site.com"
    url_from_related_path = Item.get_original_url(Nokogiri::HTML(@content), @source_website)
    url_from_related_path.should == @crawler.send(:get_base_domain_name_of_current_page) + related_url
    url_from_related_path.should =~ /^http/
  end


  it "should new_by_html" do
    item = Item.new_by_html(Nokogiri::HTML(@content), @source_website)
    item.original_url.should == @original_url
  end

  it "duplicated original_url should be invalid" do
    item = Item.new_by_html(Nokogiri::HTML(@content), @source_website)
    item.valid?.should == true
    item.save!
    invalid_item = Item.new(:original_url => item.original_url)
    invalid_item.invalid?.should == true
  end
end
