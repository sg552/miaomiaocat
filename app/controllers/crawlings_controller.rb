class CrawlingsController < ApplicationController
  # GET /crawlings
  # GET /crawlings.json
  def index
    @crawlings = Crawling.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @crawlings }
    end
  end

  # GET /crawlings/1
  # GET /crawlings/1.json
  def show
    @crawling = Crawling.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @crawling }
    end
  end

  # GET /crawlings/new
  # GET /crawlings/new.json
  def new
    @crawling = Crawling.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @crawling }
    end
  end

  # GET /crawlings/1/edit
  def edit
    @crawling = Crawling.find(params[:id])
  end

  # POST /crawlings
  # POST /crawlings.json
  def create
    @crawling = Crawling.new(params[:crawling])

    respond_to do |format|
      if @crawling.save
        format.html { redirect_to @crawling, :notice => 'Crawling was successfully created.' }
        format.json { render :json => @crawling, :status => :created, :location => @crawling }
      else
        format.html { render :action => "new" }
        format.json { render :json => @crawling.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /crawlings/1
  # PUT /crawlings/1.json
  def update
    @crawling = Crawling.find(params[:id])

    respond_to do |format|
      if @crawling.update_attributes(params[:crawling])
        format.html { redirect_to @crawling, :notice => 'Crawling was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @crawling.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /crawlings/1
  # DELETE /crawlings/1.json
  def destroy
    @crawling = Crawling.find(params[:id])
    @crawling.destroy

    respond_to do |format|
      format.html { redirect_to crawlings_url }
      format.json { head :no_content }
    end
  end
end
