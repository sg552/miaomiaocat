require 'spec_helper'

describe SourceWebsitesController do
  before do
    @crawler = create(:crawler)
    @source_website = @crawler.source_website
  end
  it "should get index" do
    get :index
    response.should be_success
  end
  #it "should post fetch action" do
  #  @crawler.update_attribute(:max_pages_per_fetch, 3)
  #  post :fetch, :id => @source_website.id
  #  response.should be_success
  #end
end
