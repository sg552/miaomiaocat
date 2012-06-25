class ItemsController < ApplicationController
  # GET /items
  # GET /items.json
  def index
    page = params[:page] || 1
    key_word = params[:key_word] || ""
    per_page = params[:per_page] || 50
    s = Tire.search 'items' do
      unless key_word.blank?
        query do
          string(key_word)
        end
      end
      sort { by :created_at, 'desc' }
      size per_page
      from (page.to_i - 1) * per_page
    end
    @items = s.results
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @items }
    end
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @item = Item.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @item }
    end
  end

end
