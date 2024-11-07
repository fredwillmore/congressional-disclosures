require 'rails_helper'

RSpec.feature "HomePage", type: :feature do
  scenario "User visits the homepage" do
    visit root_path

    expect(page).to have_valid_html
    expect(page).to have_content("Congressional Disclosures Project")
    expect(page).to have_css("turbo-frame", id: "legislator_turbo_frame")
  end
end
