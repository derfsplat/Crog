class HomeController < ApplicationController
  def index
    @blog_posts = BlogPost.where(:ispublished => true).order('publishdate desc')
  end
end
