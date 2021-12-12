class CreateRecipeimages < ActiveRecord::Migration[5.2]
  def change
    create_table :recipeimages do |t|
      t.string :image
      t.references :recipe
      
      t.timestamps
    end
  end
end
