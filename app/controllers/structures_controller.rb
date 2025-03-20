class StructuresController < ApplicationController
  before_action :set_parcel
  before_action :set_structure, only: [ :edit, :update, :destroy ]

  # GET /structures or /structures.json
  def index
    @structures = @parcel.structures
    @structure = Structure.new
  end

  # GET /structures/new
  def new
    @structure = @parcel.structures.build
  end

  # GET /structures/1/edit
  def edit
  end

  # POST /structures or /structures.json
  def create
    @structure = @parcel.structures.build(structure_params)

    respond_to do |format|
      if @structure.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("structures", partial: "structures/structure", locals: { structure: @structure }),
            turbo_stream.update("structure_form", "")
          ]
        end
        format.html { redirect_to parcel_structures_path(@parcel), notice: "Structure was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /structures/1 or /structures/1.json
  def update
    respond_to do |format|
      if @structure.update(structure_params)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(@structure, partial: "structures/structure", locals: { structure: @structure }),
            turbo_stream.update("structure_form", "")
          ]
        end
        format.html { redirect_to parcel_structures_path(@parcel), notice: "Structure was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /structures/1 or /structures/1.json
  def destroy
    @structure.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@structure) }
      format.html { redirect_to parcel_structures_path(@parcel), notice: "Structure was successfully deleted." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_parcel
      @parcel = Parcel.find(params[:parcel_id])
    end

    def set_structure
      @structure = @parcel.structures.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def structure_params
      params.require(:structure).permit(:nickname, :building_type, :length, :width)
    end
end
