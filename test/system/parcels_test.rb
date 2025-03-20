require "application_system_test_case"

class ParcelsTest < ApplicationSystemTestCase
  setup do
    @parcel = parcels(:one)
  end

  test "visiting the index" do
    visit parcels_url
    assert_selector "h1", text: "Parcels"
  end

  test "should create parcel" do
    visit parcels_url
    click_on "New parcel"

    fill_in "City", with: @parcel.city
    fill_in "State", with: @parcel.state
    fill_in "Street1", with: @parcel.street1
    fill_in "Street2", with: @parcel.street2
    fill_in "Zip code", with: @parcel.zip_code
    click_on "Create Parcel"

    assert_text "Parcel was successfully created"
    click_on "Back"
  end

  test "should update Parcel" do
    visit parcel_url(@parcel)
    click_on "Edit this parcel", match: :first

    fill_in "City", with: @parcel.city
    fill_in "State", with: @parcel.state
    fill_in "Street1", with: @parcel.street1
    fill_in "Street2", with: @parcel.street2
    fill_in "Zip code", with: @parcel.zip_code
    click_on "Update Parcel"

    assert_text "Parcel was successfully updated"
    click_on "Back"
  end

  test "should destroy Parcel" do
    visit parcel_url(@parcel)
    click_on "Destroy this parcel", match: :first

    assert_text "Parcel was successfully destroyed"
  end
end
