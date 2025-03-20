require 'rails_helper'

RSpec.describe "ParcelWizard", type: :request do
  describe "GET /parcel_wizard/address" do
    context "when creating a new parcel" do
      it "returns a successful response" do
        get address_parcel_wizard_path
        expect(response).to be_successful
      end
    end

    context "when editing an existing parcel" do
      let(:parcel) { create(:parcel) }

      it "returns a successful response" do
        get address_parcel_wizard_path(id: parcel)
        expect(response).to be_successful
      end
    end
  end

  describe "PATCH /parcel_wizard/update_address" do
    context "with valid parameters" do
      let(:valid_attributes) do
        {
          street1: "123 Main St",
          city: "Cincinnati",
          state: "OH",
          zip_code: "45202"
        }
      end

      it "creates a new parcel and redirects" do
        expect {
          patch update_address_parcel_wizard_path, params: { parcel: valid_attributes }
        }.to change(Parcel, :count).by(1)

        expect(response).to redirect_to(parcels_path)
      end

      context "when updating an existing parcel" do
        let(:parcel) { create(:parcel) }

        it "updates the parcel and redirects" do
          patch update_address_parcel_wizard_path(id: parcel), params: { parcel: valid_attributes }

          parcel.reload
          expect(parcel.street1).to eq("123 Main St")
          expect(parcel.city).to eq("Cincinnati")
          expect(response).to redirect_to(parcels_path)
        end
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        {
          street1: "",
          city: "",
          state: "Invalid",
          zip_code: "not-a-zip"
        }
      end

      it "returns unprocessable entity status" do
        patch update_address_parcel_wizard_path, params: { parcel: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a new parcel" do
        expect {
          patch update_address_parcel_wizard_path, params: { parcel: invalid_attributes }
        }.not_to change(Parcel, :count)
      end

      context "when updating an existing parcel" do
        let(:parcel) { create(:parcel) }
        let(:original_street1) { parcel.street1 }

        it "does not update the parcel" do
          patch update_address_parcel_wizard_path(id: parcel), params: { parcel: invalid_attributes }

          parcel.reload
          expect(parcel.street1).to eq(original_street1)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
