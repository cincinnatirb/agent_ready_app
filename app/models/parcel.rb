class Parcel < ApplicationRecord
  has_many :structures, dependent: :destroy
end
