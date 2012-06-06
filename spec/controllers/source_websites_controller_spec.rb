require 'spec_helper'

describe SourceWebsitesController do
  before do
    create(:source_website)
  end
  it "should get index" do
    get :index
    response.should be_success
  end
  it "should post fetch action" do
    SourceWebsite.first.update_attribute(:max_pages_per_fetch, 3)
    post :fetch, :id => SourceWebsite.first.id
    response.should be_success
  end
end
