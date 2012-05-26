class SourceWebsitesController < ApplicationController
  # GET /source_websites
  # GET /source_websites.json
  def index
    @source_websites = SourceWebsite.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @source_websites }
    end
  end

  # GET /source_websites/1
  # GET /source_websites/1.json
  def show
    @source_website = SourceWebsite.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @source_website }
    end
  end

  # GET /source_websites/new
  # GET /source_websites/new.json
  def new
    @source_website = SourceWebsite.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @source_website }
    end
  end

  # GET /source_websites/1/edit
  def edit
    @source_website = SourceWebsite.find(params[:id])
  end

  # POST /source_websites
  # POST /source_websites.json
  def create
    @source_website = SourceWebsite.new(params[:source_website])

    respond_to do |format|
      if @source_website.save
        format.html { redirect_to @source_website, :notice => 'Source website was successfully created.' }
        format.json { render :json => @source_website, :status => :created, :location => @source_website }
      else
        format.html { render :action => "new" }
        format.json { render :json => @source_website.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /source_websites/1
  # PUT /source_websites/1.json
  def update
    @source_website = SourceWebsite.find(params[:id])

    respond_to do |format|
      if @source_website.update_attributes(params[:source_website])
        format.html { redirect_to source_websites_path, :notice => 'Source website was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @source_website.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /source_websites/1
  # DELETE /source_websites/1.json
  def destroy
    @source_website = SourceWebsite.find(params[:id])
    @source_website.destroy

    respond_to do |format|
      format.html { redirect_to source_websites_url }
      format.json { head :no_content }
    end
  end
end
