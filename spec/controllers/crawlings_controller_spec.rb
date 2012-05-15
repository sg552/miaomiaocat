require 'spec_helper'

describe CrawlingsController do

  # This should return the minimal set of attributes required to create a valid
  # Crawling. As you add validations to Crawling, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # CrawlingsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  it "should GET index" do
    get :index
    response.should be_success
  end

  describe "GET show" do
    it "assigns the requested crawling as @crawling" do
      crawling = Crawling.create! valid_attributes
      get :show, {:id => crawling.to_param}, valid_session
      assigns(:crawling).should eq(crawling)
    end
  end

  describe "GET new" do
    it "assigns a new crawling as @crawling" do
      get :new, {}, valid_session
      assigns(:crawling).should be_a_new(Crawling)
    end
  end

  describe "GET edit" do
    it "assigns the requested crawling as @crawling" do
      crawling = Crawling.create! valid_attributes
      get :edit, {:id => crawling.to_param}, valid_session
      assigns(:crawling).should eq(crawling)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Crawling" do
        expect {
          post :create, {:crawling => valid_attributes}, valid_session
        }.to change(Crawling, :count).by(1)
      end

      it "assigns a newly created crawling as @crawling" do
        post :create, {:crawling => valid_attributes}, valid_session
        assigns(:crawling).should be_a(Crawling)
        assigns(:crawling).should be_persisted
      end

      it "redirects to the created crawling" do
        post :create, {:crawling => valid_attributes}, valid_session
        response.should redirect_to(Crawling.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved crawling as @crawling" do
        # Trigger the behavior that occurs when invalid params are submitted
        Crawling.any_instance.stub(:save).and_return(false)
        post :create, {:crawling => {}}, valid_session
        assigns(:crawling).should be_a_new(Crawling)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Crawling.any_instance.stub(:save).and_return(false)
        post :create, {:crawling => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested crawling" do
        crawling = Crawling.create! valid_attributes
        # Assuming there are no other crawlings in the database, this
        # specifies that the Crawling created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Crawling.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => crawling.to_param, :crawling => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested crawling as @crawling" do
        crawling = Crawling.create! valid_attributes
        put :update, {:id => crawling.to_param, :crawling => valid_attributes}, valid_session
        assigns(:crawling).should eq(crawling)
      end

      it "redirects to the crawling" do
        crawling = Crawling.create! valid_attributes
        put :update, {:id => crawling.to_param, :crawling => valid_attributes}, valid_session
        response.should redirect_to(crawling)
      end
    end

    describe "with invalid params" do
      it "assigns the crawling as @crawling" do
        crawling = Crawling.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Crawling.any_instance.stub(:save).and_return(false)
        put :update, {:id => crawling.to_param, :crawling => {}}, valid_session
        assigns(:crawling).should eq(crawling)
      end

      it "re-renders the 'edit' template" do
        crawling = Crawling.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Crawling.any_instance.stub(:save).and_return(false)
        put :update, {:id => crawling.to_param, :crawling => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested crawling" do
      crawling = Crawling.create! valid_attributes
      expect {
        delete :destroy, {:id => crawling.to_param}, valid_session
      }.to change(Crawling, :count).by(-1)
    end

    it "redirects to the crawlings list" do
      crawling = Crawling.create! valid_attributes
      delete :destroy, {:id => crawling.to_param}, valid_session
      response.should redirect_to(crawlings_url)
    end
  end

end
