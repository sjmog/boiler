require "rails_helper"

RSpec.describe "Home", type: :system do
  scenario "User visits the homepage" do
    visit root_path

    expect(page).to have_content("dewey2")
    # Add more expectations based on what should be on your homepage
  end
end
