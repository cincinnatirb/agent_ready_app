require 'rails_helper'

RSpec.describe "Structures", type: :request do
  let(:structure) { create(:structure) }

  describe "GET /structures" do
    it "returns a successful response" do
      get structures_url
      expect(response).to be_successful
    end
  end

  describe "GET /structures/:id" do
    it "returns a successful response" do
      get structure_url(structure)
      expect(response).to be_successful
    end
  end

  describe "GET /structures/new" do
    it "returns a successful response" do
      get new_structure_url
      expect(response).to be_successful
    end
  end

  describe "GET /structures/:id/edit" do
    it "returns a successful response" do
      get edit_structure_url(structure)
      expect(response).to be_successful
    end
  end

  describe "POST /structures" do
    let(:valid_attributes) do
      {
        building_type: "Commercial",
        length: 100,
        width: 50,
        nickname: "Office Building",
        parcel_id: create(:parcel).id
      }
    end

    it "creates a new structure" do
      expect {
        post structures_url, params: { structure: valid_attributes }
      }.to change(Structure, :count).by(1)

      expect(response).to redirect_to(structure_url(Structure.last))
    end
  end

  describe "PATCH /structures/:id" do
    let(:new_attributes) do
      {
        building_type: "Updated Building Type",
        length: 100,
        nickname: "Updated Nickname",
        width: 50
      }
    end

    it "updates the requested structure" do
      patch structure_url(structure), params: { structure: new_attributes }
      structure.reload

      expect(structure.building_type).to eq("Updated Building Type")
      expect(structure.length).to eq(100)
      expect(structure.nickname).to eq("Updated Nickname")
      expect(structure.width).to eq(50)
      expect(response).to redirect_to(structure_url(structure))
    end
  end

  describe "DELETE /structures/:id" do
    it "destroys the requested structure" do
      structure_to_delete = create(:structure)

      expect {
        delete structure_url(structure_to_delete)
      }.to change(Structure, :count).by(-1)

      expect(response).to redirect_to(structures_url)
      expect(response).to have_http_status(:see_other)
    end
  end
end
