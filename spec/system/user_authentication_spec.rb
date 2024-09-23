require "rails_helper"

RSpec.describe "User Authentication", type: :system, js: true do
  scenario "User can sign up" do
    email = "test@example.com"
    password = "Password123"

    visit new_user_registration_path

    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Sign in or Sign up"

    expect(page).to have_button("sign out")
    expect(User.find_by(email: email)).to be_present
  end

  scenario "User can sign out" do
    sign_in create(:user)
    visit root_path
    click_button "sign out"

    expect(page).to have_link("sign in")
    expect(page).to have_current_path(root_path)
  end

  scenario "User can sign in with existing account" do
    user = create(:user)

    visit new_user_registration_path

    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in or Sign up"

    expect(page).to have_button("sign out")
    expect(page).to have_current_path(root_path)
  end

  scenario "User gets a toast with a notice when they sign in with an email and enter invalid credentials" do
    user = create(:user)

    visit new_user_registration_path

    fill_in "Email", with: user.email
    fill_in "Password", with: "InvalidPassword"
    click_button "Sign in or Sign up"

    expect(page).to have_content("Invalid email or password")
  end

  scenario "User can sign in with Google" do
    visit new_user_registration_path

    click_button "Sign in with Google"

    expect(page).to have_button("sign out")
    expect(page).to have_current_path(root_path)
  end

  scenario "Handling a Google authentication error" do
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

    visit new_user_registration_path

    click_button "Sign in with Google"

    expect(page).to have_content("Invalid credentials")
  end
end
