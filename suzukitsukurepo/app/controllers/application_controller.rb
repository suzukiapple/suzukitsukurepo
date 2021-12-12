# coding: utf-8
class ApplicationController < ActionController::Base
  helper_method :usernamearray, :usernamehash, :thumburl, :galleryurl, :nowloadingurl
  
  def usernamearray
    %w(ななしさん りょう まみ)
  end

  def usernamehash
    (usernamearray()).map.with_index do |name, i|
      [name, i]
    end
  end

  def thumburl(url)
    url.gsub(/([^\/]+?)$/, "thumb.jpg")
  end

  def galleryurl(url)
    url.gsub(/([^\/]+?)$/, "gallery.jpg")
  end

  def nowloadingurl
    "#{config.relative_url_root}/nowloading.html"
  end
  
end
