require 'spec_helper'
describe MockBrowser do
  it "should open www.baidu.com" do
    content = MockBrowser.get("http://www.baidu.com")
  end
end

