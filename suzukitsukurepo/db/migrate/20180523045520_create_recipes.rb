class CreateRecipes < ActiveRecord::Migration[5.2]
  def change
    create_table :recipes do |t|
      t.string :name
      t.string :memo
      t.string :url
      t.string :html
      t.integer :good, default: 0
      t.integer :user, default: 0
      t.integer :order, default: 0
      t.date :last_cocked
      t.boolean :isloading, default: false, null: false
      t.timestamps
    end
  end
end
