class WithGallery < ActiveRecord::Base
  attr_accessible :gallery_id, :photo_id
  belongs_to :photo
  belongs_to :gallery
end
