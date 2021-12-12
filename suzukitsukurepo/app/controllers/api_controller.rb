class ApiController < ApplicationController

  def updategoodcount
    recipe=Recipe.find(params[:recipeid])
    recipe.good+=params[:count].to_i
    respond_to do |format|
      if recipe.save
        format.json { render json: recipe, status: 200 }
      else
        format.json { render json: {}, status: 200 }
      end
    end
  end

  def saverecipeimage
    if params[:recipeimage].nil? then
      result={result: false}
    else
      params[:recipeimage][:image].each do |image|
        recipeimage=Recipeimage.new
        recipeimage.recipe_id=params[:recipe][:id]
        recipeimage.image=image
        recipeimage.save
      end
      result={result: true}
    end
    respond_to do |format|
      format.json { render json: result, status: 200 }
    end
  end
  private
  
end
