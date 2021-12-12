class OrdersController < ApplicationController
  protect_from_forgery with: :null_session

  def index
    @recipes = Recipe.all.order({ order: :asc }, { created_at: :desc})
  end
  
  def update
    params[:orderparams].split(",").each_with_index do |recipeid,i|
      recipe=Recipe.find(recipeid)
      recipe.order=i
      recipe.save!
    end
    
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Order was successfully changed.' }
    end
  end

  private
  def order_params
    params.require(:order).permit(:orderparams)
  end
  
end
