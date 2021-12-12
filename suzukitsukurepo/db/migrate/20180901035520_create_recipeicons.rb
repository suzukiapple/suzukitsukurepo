class CreateRecipeicons < ActiveRecord::Migration[5.2]
  def change
    create_table :recipeicons do |t|
      t.references :recipe, foreign_key: true
      t.references :icon, foreign_key: true

      t.timestamps
    end
  end
end
