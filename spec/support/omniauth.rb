require "omniauth"

OmniAuth.config.test_mode = true

OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
  provider: 'google_oauth2',
  uid: '123545',
  info: {
    email: 'test@example.com',
    first_name: 'Test',
    last_name: 'User'
  },
  credentials: {
    token: 'mock_token',
    refresh_token: 'mock_refresh_token'
  }
})