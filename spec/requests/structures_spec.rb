require 'rails_helper'

RSpec.describe "Structures", type: :request do
  let(:parcel) { create(:parcel) }
  let(:valid_attributes) { { nickname: "Main House", building_type: "residential", length: 50, width: 30 } }
  let(:invalid_attributes) { { nickname: "", building_type: "", length: nil, width: nil } }

  describe "GET /parcels/:parcel_id/structures" do
    it "renders a successful response" do
      get parcel_structures_path(parcel)
      expect(response).to be_successful
    end

    it "displays existing structures" do
      structure = create(:structure, parcel: parcel, nickname: "Main House")
      get parcel_structures_path(parcel)
      expect(response.body).to include("Main House")
    end
  end

  describe "GET /parcels/:parcel_id/structures/new" do
    it "renders a successful response" do
      get new_parcel_structure_path(parcel)
      expect(response).to be_successful
    end

    context "with turbo_frame request" do
      it "renders the form within the frame" do
        get new_parcel_structure_path(parcel), headers: { "Turbo-Frame" => "structure_form" }
        expect(response.body).to include('turbo-frame id="structure_form"')
      end
    end
  end

  describe "GET /parcels/:parcel_id/structures/:id/edit" do
    it "renders a successful response" do
      structure = create(:structure, parcel: parcel)
      get edit_parcel_structure_path(parcel, structure)
      expect(response).to be_successful
    end

    context "with turbo_frame request" do
      it "renders the form within the frame" do
        structure = create(:structure, parcel: parcel)
        get edit_parcel_structure_path(parcel, structure), headers: { "Turbo-Frame" => "structure_form" }
        expect(response.body).to include('turbo-frame id="structure_form"')
      end
    end
  end

  describe "POST /parcels/:parcel_id/structures" do
    context "with valid parameters" do
      it "creates a new structure" do
        expect {
          post parcel_structures_path(parcel), params: { structure: valid_attributes }
        }.to change(Structure, :count).by(1)
      end

      context "with turbo_stream request" do
        it "returns turbo_stream response" do
          post parcel_structures_path(parcel),
               params: { structure: valid_attributes },
               headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(response.media_type).to eq Mime[:turbo_stream]
        end
      end
    end

    context "with invalid parameters" do
      it "does not create a new structure" do
        expect {
          post parcel_structures_path(parcel), params: { structure: invalid_attributes }
        }.to change(Structure, :count).by(0)
      end

      it "renders a response with 422 status" do
        post parcel_structures_path(parcel), params: { structure: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /parcels/:parcel_id/structures/:id" do
    let(:structure) { create(:structure, parcel: parcel) }
    let(:new_attributes) { { nickname: "Updated House" } }

    context "with valid parameters" do
      it "updates the requested structure" do
        patch parcel_structure_path(parcel, structure), params: { structure: new_attributes }
        structure.reload
        expect(structure.nickname).to eq("Updated House")
      end

      context "with turbo_stream request" do
        it "returns turbo_stream response" do
          patch parcel_structure_path(parcel, structure),
                params: { structure: new_attributes },
                headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(response.media_type).to eq Mime[:turbo_stream]
        end
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status" do
        patch parcel_structure_path(parcel, structure), params: { structure: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /parcels/:parcel_id/structures/:id" do
    it "destroys the requested structure" do
      structure = create(:structure, parcel: parcel)
      expect {
        delete parcel_structure_path(parcel, structure)
      }.to change(Structure, :count).by(-1)
    end

    context "with turbo_stream request" do
      it "returns turbo_stream response" do
        structure = create(:structure, parcel: parcel)
        delete parcel_structure_path(parcel, structure),
               headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response.media_type).to eq Mime[:turbo_stream]
      end
    end
  end
end
