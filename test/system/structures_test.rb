require "application_system_test_case"

class StructuresTest < ApplicationSystemTestCase
  setup do
    @structure = structures(:one)
  end

  test "visiting the index" do
    visit structures_url
    assert_selector "h1", text: "Structures"
  end

  test "should create structure" do
    visit structures_url
    click_on "New structure"

    fill_in "Building type", with: @structure.building_type
    fill_in "Length", with: @structure.length
    fill_in "Nickname", with: @structure.nickname
    fill_in "Parcel", with: @structure.parcel_id
    fill_in "Width", with: @structure.width
    click_on "Create Structure"

    assert_text "Structure was successfully created"
    click_on "Back"
  end

  test "should update Structure" do
    visit structure_url(@structure)
    click_on "Edit this structure", match: :first

    fill_in "Building type", with: @structure.building_type
    fill_in "Length", with: @structure.length
    fill_in "Nickname", with: @structure.nickname
    fill_in "Parcel", with: @structure.parcel_id
    fill_in "Width", with: @structure.width
    click_on "Update Structure"

    assert_text "Structure was successfully updated"
    click_on "Back"
  end

  test "should destroy Structure" do
    visit structure_url(@structure)
    click_on "Destroy this structure", match: :first

    assert_text "Structure was successfully destroyed"
  end
end
