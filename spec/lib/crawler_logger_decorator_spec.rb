require 'spec_helper'
describe CrawlerLoggerDecorator do
  it "should be initialized" do
    @crawler = create(:crawler)
    @crawler.logger.info "starts..."
    logged_text = `tail #{@crawler.logger.logger.outputters.first.filename} -n 1`
    # got : 08:53:19 INFO: (mocked site): starts...
    logged_text.include?(@crawler.source_website.name).should == true
    logged_text.include?("INFO").should == true
  end
end
