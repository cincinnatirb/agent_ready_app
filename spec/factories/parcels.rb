FactoryBot.define do
  factory :parcel do
    sequence(:street1) { |n| "#{n} Main St" }
    sequence(:street2) { |n| "Suite #{n}" }
    sequence(:city) { |n| "City #{n}" }
    state { "OH" }
    sequence(:zip_code) { |n| sprintf("%05d", n % 100000) }
  end
end
