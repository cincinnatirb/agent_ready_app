require "test_helper"

class StructuresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @structure = structures(:one)
  end

  test "should get index" do
    get structures_url
    assert_response :success
  end

  test "should get new" do
    get new_structure_url
    assert_response :success
  end

  test "should create structure" do
    assert_difference("Structure.count") do
      post structures_url, params: { structure: { building_type: @structure.building_type, length: @structure.length, nickname: @structure.nickname, parcel_id: @structure.parcel_id, width: @structure.width } }
    end

    assert_redirected_to structure_url(Structure.last)
  end

  test "should show structure" do
    get structure_url(@structure)
    assert_response :success
  end

  test "should get edit" do
    get edit_structure_url(@structure)
    assert_response :success
  end

  test "should update structure" do
    patch structure_url(@structure), params: { structure: { building_type: @structure.building_type, length: @structure.length, nickname: @structure.nickname, parcel_id: @structure.parcel_id, width: @structure.width } }
    assert_redirected_to structure_url(@structure)
  end

  test "should destroy structure" do
    assert_difference("Structure.count", -1) do
      delete structure_url(@structure)
    end

    assert_redirected_to structures_url
  end
end
