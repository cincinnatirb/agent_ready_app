class Parcel < ApplicationRecord
  has_many :structures, dependent: :destroy
  accepts_nested_attributes_for :structures, allow_destroy: true

  validates :street1, presence: true, length: { maximum: 100 }
  validates :street2, length: { maximum: 100 }
  validates :city, presence: true, length: { maximum: 50 }
  validates :state, presence: true, length: { is: 2 }, format: { with: /\A[A-Z]{2}\z/ }
  validates :zip_code, presence: true, format: { with: /\A\d{5}(-\d{4})?\z/, message: "should be in format 12345 or 12345-1234" }
end
