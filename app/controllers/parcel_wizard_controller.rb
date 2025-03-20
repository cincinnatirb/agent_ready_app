class ParcelWizardController < ApplicationController
  layout "parcel_wizard"
  before_action :set_parcel, only: [ :address, :update_address ]

  def address
    @parcel ||= Parcel.new
  end

  def update_address
    @parcel ||= Parcel.new
    if @parcel.update(address_params)
      redirect_to next_wizard_path, turbo_frame: "_top"
    else
      render :address, status: :unprocessable_entity
    end
  end

  private

  def set_parcel
    @parcel = Parcel.find(params[:id]) if params[:id]
  end

  def address_params
    params.require(:parcel).permit(:street1, :street2, :city, :state, :zip_code)
  end

  def next_wizard_path
    # This will be updated when we add the next step
    parcels_path
  end
end
