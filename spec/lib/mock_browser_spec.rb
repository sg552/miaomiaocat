require 'spec_helper'
describe MockBrowser do
  it "should open www.baidu.com" do
    html_content = MockBrowser.get("http://www.baidu.com")
    html_content.include?("<html>").should == true
    html_content.include?("</html>").should == true
  end

  it "should get URI, e.g. URI.new('spec/fixtures/page1.html')" do
    file = 'file://spec/fixtures/page1_the_simplest.html'
    MockBrowser.get(file).should == IO.read(file.gsub('file://', ''))
  end
end

