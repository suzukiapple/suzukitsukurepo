class HtmlGeneratorJob < ApplicationJob
  include Mechanize_base64
  queue_as :default

  def perform(*args)
    # Do something later
    recipes=Recipe.where(isloading: true).order('created_at DESC')
    recipes.each do |recipe|
      generateHtml(recipe)
    end
  end

  def generateHtml(recipe)
    html = gethtml(recipe.url)
    filename = "./tmp/html/#{rand(1<<100)}.html"
    File.open(filename, "w+") do |f|
      f.write html
    end
    File.open(filename) do |f|
      recipe.html = f
    end
    recipe.isloading=false
    recipe.save
    File.delete(filename)
  end

  def gethtml(url)
    agent = Mechanize.new
    agent.request_headers = {
      "user-agent"=>"Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1",
    }
    agent.get url
    agent.page.embed_body
  end
  
end


