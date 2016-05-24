class CategoriesController < ApplicationController
  # GET /categories
  # GET /categories.json
  def index
    respond_to do |format|
      format.html do
        render layout: 'basic'
      end
      format.json do
        if params[:meta]
          NestedCategories.meta
        elsif params[:parent_id]
        else
          @categories = NestedCategories.all
        end
        render json: @categories
      end
    end
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
    @category = if params[:id] 
                  NestedCategory.find( params[:id] )
                elsif params[:top_level_name]
                  parent_category = NestedCategory.by_name(  params[:top_level_name] ).first
                  if params[:subcategory_name]
                    parent_category.children.by_name( params[:subcategory_name] ).first
                  else
                    parent_category
                  end
                end
    if @category.nil?
      raise ActionController::RoutingError, 'no category found'
    end

    respond_to do |format|
      format.html do
        render layout: 'basic'
      end
      format.json { render json: @category }
    end
  end

  # GET /categories/new
  # GET /categories/new.json
  def new
    @category = Category.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @category }
    end
  end

  # GET /categories/1/edit
  def edit
    @category = Category.find(params[:id])
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(params[:category])

    respond_to do |format|
      if @category.save
        format.html { redirect_to @category, notice: 'Category was successfully created.' }
        format.json { render json: @category, status: :created, location: @category }
      else
        format.html { render action: 'new' }
        format.json { render :json => @category.errors, status => :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.json
  def update
    @category = Category.find(params[:id])
    success = @category.update_attributes(params[:category])

    respond_to do |format|
      if success
        format.html { redirect_to @category, notice: 'Category was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category = Category.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.html { redirect_to categories_url }
      format.json { head :no_content }
    end
  end
end
