class HomeController < ApplicationController
  def index
    @posts = BlogPost.where(:ispublished => true).order('publishdate desc')
  end
end
