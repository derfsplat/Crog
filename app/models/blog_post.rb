class BlogPost < ActiveRecord::Base
  attr_accessible :content, :publishdate, :title, :ispublished
end
