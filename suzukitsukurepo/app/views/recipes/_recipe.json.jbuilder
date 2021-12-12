json.extract! recipe, :id, :name, :memo, :url, :html, :good, :user, :created_at, :updated_at
json.url recipe_url(recipe, format: :json)
