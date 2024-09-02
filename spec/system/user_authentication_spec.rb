require "rails_helper"

RSpec.describe "User Authentication", type: :system do
  let(:email) { "test@example.com" }
  let(:password) { "password123" }

  scenario "User can sign up" do
    visit new_user_registration_path

    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Sign in or Sign up"

    expect(page).to have_content("Welcome! You have signed up successfully.")
    expect(User.find_by(email: email)).to be_present
  end

  scenario "User can sign out" do
    user = User.create!(email: email, password: password)
    sign_in user
    visit root_path
    click_button "sign out"

    expect(page).to have_content("Signed out successfully.")
    expect(page).to have_current_path(root_path)
  end

  scenario "User can sign in with existing account" do
    User.create!(email: email, password: password)

    visit new_user_registration_path

    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Sign in or Sign up"

    expect(page).to have_button("sign out")
    expect(page).to have_current_path(root_path)
  end
end
