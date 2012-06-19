class ItemsController < ApplicationController
  # GET /items
  # GET /items.json
  def index
    @key_word = params[:key_word]
    @items = Item.where(:content =>/#{@key_word}/).desc(:created_at).page params[:page]
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
