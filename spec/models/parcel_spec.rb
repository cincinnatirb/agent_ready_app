require 'rails_helper'

RSpec.describe Parcel, type: :model do
  describe 'associations' do
    it { should have_many(:structures).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:parcel) }
    it { should validate_presence_of(:street1) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:zip_code) }
  end
end
