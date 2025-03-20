class ParcelsController < ApplicationController
  before_action :set_parcel, only: [ :edit, :update, :show, :destroy, :review ]

  # GET /parcels or /parcels.json
  def index
    @parcels = Parcel.all
  end

  # GET /parcels/chat
  def chat
  end

  # POST /parcels/process_chat
  def process_chat
    llm_service = LlmService.new

    # Read auditor data file
    auditor_data = File.read(Rails.root.join("auditor_data.txt"))

    # Define the JSON Schema for the response
    json_schema = ParcelEntrySchema.schema

    result = llm_service.chat_with_structured_output(
      "You must look up the actual parcel information from authoritative sources like the county auditor's website or property records. Do not make up or guess information. If you cannot find the structure information with confidence, simply return the address information the user passed in.

Here is some auditor data that may be helpful. If the address matches something in this data, prefer this information over other sources:

#{auditor_data}

The address to look up is: #{params[:address]}",
      json_schema
    )

    puts "Result: #{result}"

    @parcel = Parcel.new(result[:structured_output]["parcel"])
    @structures = result[:structured_output]["structures"].map { |s| Structure.new(s.merge(parcel: @parcel)) }

    if @parcel.valid? && @structures.all?(&:valid?)
      @parcel.save
      @structures.each do |structure|
        structure.parcel = @parcel
        structure.save
      end
      redirect_to review_parcel_path(@parcel), notice: "Parcel was successfully created from chat."
    else
      puts "Error: #{@parcel.errors.full_messages}"
      puts "Structures errors: #{@structures.map(&:errors).flatten}"
      flash.now[:alert] = "Could not create parcel from chat response. Please try again."
      render :chat, status: :unprocessable_entity
    end
    # rescue StandardError => e
    #   Rails.logger.error("Error processing chat: #{e.message}")
    #   flash.now[:alert] = "Error processing chat: #{e.message}"
    #   render :chat, status: :unprocessable_entity
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
        redirect_to parcels_path, notice: "Parcel was successfully created."
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
