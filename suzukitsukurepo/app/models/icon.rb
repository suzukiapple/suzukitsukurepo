class Icon < ApplicationRecord
  has_many :recipeicons, dependent: :destroy
  has_many :recipes, :through => :recipeicons
end
