class Tag < ApplicationRecord
  belongs_to :creator, class_name: 'Person'
  belongs_to :modified_by, class_name: 'Person'
  belongs_to :taggings
  has_many :taggings


end
