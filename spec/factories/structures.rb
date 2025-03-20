FactoryBot.define do
  factory :structure do
    building_type { "residential" }
    length { 50 }
    width { 30 }
    nickname { "Main House" }
    association :parcel
  end
end
