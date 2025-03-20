class Structure < ApplicationRecord
  belongs_to :parcel

  enum :building_type, {
    residential: "residential",
    garage: "garage",
    shed: "shed",
    workshop: "workshop",
    barn: "barn",
    other: "other"
  }

  validates :building_type, :length, :width, presence: true
  validates :length, :width, numericality: { greater_than: 0 }, allow_nil: true
end
