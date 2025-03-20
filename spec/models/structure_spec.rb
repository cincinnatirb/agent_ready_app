require 'rails_helper'

RSpec.describe Structure, type: :model do
  describe 'associations' do
    it { should belong_to(:parcel) }
  end

  describe 'validations' do
    subject { build(:structure) }
    it { should validate_presence_of(:building_type) }
    it { should validate_presence_of(:length) }
    it { should validate_presence_of(:width) }
  end
end
