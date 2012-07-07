class CrawlersController < ApplicationController
  before_filter :get_by_id, :only => [:edit, :update, :destroy]

  def edit
  end
  def update
    @crawler.update_attributes(params[:crawler])
    redirect_to edit_source_website_path(@crawler.source_website), :notice => "crawler successfully updated"
  end
  def create
    @crawler = Crawler.new(params[:crawler])
  end
  def destroy
  end
  private
  def get_by_id
    @crawler = Crawler.find(params[:id])
  end
end
