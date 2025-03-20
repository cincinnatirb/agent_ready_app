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

    # Define the JSON Schema for the response
    json_schema = {
      type: "object",
      properties: {
        parcel: {
          type: "object",
          properties: {
            street1: {
              type: "string",
              maxLength: 100,
              description: "Primary street address"
            },
            street2: {
              type: "string",
              maxLength: 100,
              description: "Secondary address line (apartment, suite, etc.)"
            },
            city: {
              type: "string",
              maxLength: 50,
              description: "City name"
            },
            state: {
              type: "string",
              pattern: "^[A-Z]{2}$",
              description: "Two-letter state code"
            },
            zip_code: {
              type: "string",
              pattern: "^\\d{5}(-\\d{4})?$",
              description: "ZIP code in format 12345 or 12345-1234"
            }
          },
          required: [ "street1", "city", "state", "zip_code" ]
        },
        structures: {
          type: "array",
          items: {
            type: "object",
            properties: {
              building_type: {
                type: "string",
                enum: [ "residential", "garage", "shed", "workshop", "barn", "other" ],
                description: "Type of building"
              },
              nickname: {
                type: "string",
                description: "Optional nickname for the structure"
              },
              length: {
                type: "integer",
                minimum: 1,
                description: "Length in feet"
              },
              width: {
                type: "integer",
                minimum: 1,
                description: "Width in feet"
              }
            },
            required: [ "building_type", "length", "width" ]
          }
        }
      },
      required: [ "parcel", "structures" ]
    }

    result = llm_service.chat_with_structured_output(
      "Create a parcel with the following address and include appropriate structures: #{params[:address]}",
      json_schema
    )

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
