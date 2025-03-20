class ParcelsController < ApplicationController
  before_action :set_parcel, only: [ :edit, :update, :show, :destroy, :review ]

  # GET /parcels or /parcels.json
  def index
    @parcels = Parcel.all
  end

  # GET /parcels/new
  def new
    @parcel = Parcel.new
  end

  # POST /parcels or /parcels.json
  def create
    @parcel = Parcel.new(parcel_params)

    if @parcel.save
      if params[:next_step] == "structures"
        redirect_to parcel_structures_path(@parcel)
      else
        redirect_to edit_parcel_path(@parcel), notice: "Parcel was successfully created."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /parcels/1/edit
  def edit
  end

  # PATCH/PUT /parcels/1 or /parcels/1.json
  def update
    if @parcel.update(parcel_params)
      if params[:next_step] == "structures"
        redirect_to parcel_structures_path(@parcel)
      else
        redirect_to parcels_path, notice: "Parcel was successfully updated."
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # GET /parcels/1 or /parcels/1.json
  def show
  end

  # DELETE /parcels/1 or /parcels/1.json
  def destroy
    @parcel.destroy
    redirect_to parcels_path, notice: "Parcel was successfully deleted."
  end

  def review
    @structures = @parcel.structures
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_parcel
      @parcel = Parcel.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def parcel_params
      params.require(:parcel).permit(
        :street1, :street2, :city, :state, :zip_code,
        structures_attributes: [ :id, :nickname, :building_type, :length, :width, :_destroy ]
      )
    end
end
