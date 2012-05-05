class Photo < ActiveRecord::Base
  has_many :with_galleries, dependent: :destroy
  has_many :galleries, through: :with_galleries
  flickrizr
end
