require "rails_helper"

RSpec.describe "Home", type: :system, js: true do
  scenario "Unauthenticated user visits the homepage" do
    visit root_path

    expect(page).to have_content("boiler")
  end

  scenario "Authenticated user visits the homepage" do
    user = create(:user)
    sign_in user

    visit root_path

    expect(page).to have_content("boiler")
  end
end
