require 'spec_helper'

describe ItemsController  do
  before do
    @item = create(:item)
  end
  it "should get landing page" do
    get :index
    response.should be_success
    assigns(:items).size.should > 0
  end

  it "should get landing page with key_word" do
    key_word = 333
    @item.update_attribute(:content , "some content ..containing #{key_word} ..")

    get :index, :key_word => key_word
    response.should be_success
    assigns(:items).size.should > 0

    get :index, :key_word => "ooxx, text not contained by @item"
    response.should be_success
    assigns(:items).size.should == 0
  end
end
