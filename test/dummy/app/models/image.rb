class Image < ActiveRecord::Base
  attr_accessor :is_public, :hidden
  flickrizr image: :i
end
