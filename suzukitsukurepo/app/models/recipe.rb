class Recipe < ApplicationRecord
  mount_uploader :html, HtmlUploader
  has_many :recipeimages
  
  has_many :recipeicons, dependent: :destroy
  has_many :icons, :through => :recipeicons
  accepts_nested_attributes_for :recipeicons, allow_destroy: true
end
