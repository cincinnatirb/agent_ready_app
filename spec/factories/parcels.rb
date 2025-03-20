FactoryBot.define do
  factory :parcel do
    sequence(:street1) { |n| "#{n} Main St" }
    street2 { "Apt 1" }
    sequence(:city) { |n| "City #{n}" }
    sequence(:state) { |n| "State #{n}" }
    sequence(:zip_code) { |n| "1234#{n}" }
  end
end
