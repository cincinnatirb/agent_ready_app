require 'rails_helper'

RSpec.describe "Parcels", type: :request do
  let(:valid_attributes) do
    {
      street1: "123 Main St",
      city: "Anytown",
      state: "OH",
      zip_code: "45050"
    }
  end

  let(:invalid_attributes) do
    {
      street1: "",
      city: "",
      state: "",
      zip_code: ""
    }
  end

  describe "GET /parcels" do
    it "renders a successful response" do
      Parcel.create! valid_attributes
      get parcels_url
      expect(response).to be_successful
    end
  end

  describe "GET /parcels/new" do
    it "renders a successful response" do
      get new_parcel_url
      expect(response).to be_successful
    end
  end

  describe "GET /parcels/:id/edit" do
    it "renders a successful response" do
      parcel = Parcel.create! valid_attributes
      get edit_parcel_url(parcel)
      expect(response).to be_successful
    end
  end

  describe "GET /parcels/:id/review" do
    let(:parcel) { create(:parcel) }
    let!(:structure) { create(:structure, parcel: parcel, nickname: "Main House") }

    it "renders a successful response" do
      get review_parcel_path(parcel)
      expect(response).to be_successful
    end

    it "displays the parcel's address" do
      get review_parcel_path(parcel)
      expect(response.body).to include(parcel.street1)
      expect(response.body).to include(parcel.city)
      expect(response.body).to include(parcel.state)
      expect(response.body).to include(parcel.zip_code)
    end

    it "displays the parcel's structures" do
      get review_parcel_path(parcel)
      expect(response.body).to include("Main House")
      expect(response.body).to include("#{structure.length * structure.width} sq ft")
    end

    it "includes edit links for both address and structures" do
      get review_parcel_path(parcel)
      expect(response.body).to include(edit_parcel_path(parcel))
      expect(response.body).to include(parcel_structures_path(parcel))
    end
  end

  describe "POST /parcels" do
    context "with valid parameters" do
      it "creates a new Parcel" do
        expect {
          post parcels_url, params: { parcel: valid_attributes }
        }.to change(Parcel, :count).by(1)
      end

      it "redirects to the structures page when next_step is structures" do
        post parcels_url, params: { parcel: valid_attributes, next_step: 'structures' }
        expect(response).to redirect_to(parcel_structures_path(Parcel.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Parcel" do
        expect {
          post parcels_url, params: { parcel: invalid_attributes }
        }.to change(Parcel, :count).by(0)
      end

      it "renders a response with 422 status" do
        post parcels_url, params: { parcel: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /parcels/:id" do
    context "with valid parameters" do
      let(:new_attributes) { { street1: "456 Oak St" } }

      it "updates the requested parcel" do
        parcel = Parcel.create! valid_attributes
        patch parcel_url(parcel), params: { parcel: new_attributes }
        parcel.reload
        expect(parcel.street1).to eq("456 Oak St")
      end

      it "redirects to the structures page when next_step is structures" do
        parcel = Parcel.create! valid_attributes
        patch parcel_url(parcel), params: { parcel: new_attributes, next_step: 'structures' }
        expect(response).to redirect_to(parcel_structures_path(parcel))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status" do
        parcel = Parcel.create! valid_attributes
        patch parcel_url(parcel), params: { parcel: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /parcels/:id" do
    it "destroys the requested parcel" do
      parcel = Parcel.create! valid_attributes
      expect {
        delete parcel_url(parcel)
      }.to change(Parcel, :count).by(-1)
    end

    it "redirects to the parcels list" do
      parcel = Parcel.create! valid_attributes
      delete parcel_url(parcel)
      expect(response).to redirect_to(parcels_url)
    end
  end
end
