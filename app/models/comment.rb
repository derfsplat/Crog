class Comment < ActiveRecord::Base
  attr_accessible :blog_post_id, :comment, :email
end
