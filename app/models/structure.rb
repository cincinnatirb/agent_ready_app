class Structure < ApplicationRecord
  belongs_to :parcel

  validates :building_type, :length, :width, presence: true
end
