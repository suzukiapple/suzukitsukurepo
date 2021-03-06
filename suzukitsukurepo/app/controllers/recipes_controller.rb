# coding: utf-8
class RecipesController < ApplicationController
  require 'carrierwave/orm/activerecord'
  include Mechanize_base64
  
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]

  def gallery
    @recipeimages = Recipeimage.where("recipe_id not ?", nil).includes(:recipe).order({ order: :asc }, { created_at: :desc})
  end
  
  # GET /recipes
  # GET /recipes.json
  def index
    @recipes = Recipe.all.order({ order: :asc }, { created_at: :desc})
  end

  # GET /recipes/1
  # GET /recipes/1.json
  def show
    @recipeimages=Recipeimage.where(recipe_id: params[:id]).order({ created_at: :desc})
  end

  # GET /recipes/new
  def new
    @recipe = Recipe.new
  end

  # GET /recipes/1/edit
  def edit
  end

  # POST /recipes
  # POST /recipes.json
  def create
    @recipe = Recipe.new(recipe_params)

    if @recipe.url!="" then
      needAddHtml=true
      @recipe.isloading=true
    else
      needAddHtml=false
    end
    
    respond_to do |format|
      if @recipe.save
        if needAddHtml then
          HtmlGeneratorJob.perform_later
        end
        format.html { redirect_to @recipe, notice: 'Recipe was successfully created.' }
        format.json { render :show, status: :created, location: @recipe }
      else
        format.html { render :new }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recipes/1
  # PATCH/PUT /recipes/1.json
  def update
    if params[:recipe][:url]!="" && params[:recipe][:url]!=@recipe.url then
      needAddHtml=true
      params[:recipe][:isloading]=true
    else
      needAddHtml=false
    end
    
    respond_to do |format|
      if @recipe.update(recipe_params)
        if needAddHtml then
          HtmlGeneratorJob.perform_later
        end
        format.html { redirect_to @recipe, notice: 'Recipe was successfully updated.' }
        format.json { render :show, status: :ok, location: @recipe }
      else
        format.html { render :edit }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recipes/1
  # DELETE /recipes/1.json
  def destroy
    @recipe.destroy
    respond_to do |format|
      format.html { redirect_to recipes_url, notice: 'Recipe was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recipe
      @recipe = Recipe.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recipe_params
      params.require(:recipe).permit(:id, :name, :memo, :url, :html, :good, :user, :isloading, :last_cocked, { :icon_ids=> [] })
    end
    
end
