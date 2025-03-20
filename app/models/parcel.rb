class Parcel < ApplicationRecord
  has_many :structures, dependent: :destroy

  validates :street1, :city, :state, :zip_code, presence: true
end
