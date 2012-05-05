class Gallery < ActiveRecord::Base
  has_many :with_galleries, dependent: :destroy
  has_many :photos, through: :with_galleries
  attr_accessor :primary_photo_id
  setizr set_id: :photoset_id
end
