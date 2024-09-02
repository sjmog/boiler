Rails.application.config.middleware.use OmniAuth::Builder do
  if ENV["GOOGLE_CLIENT_ID"].present? && ENV["GOOGLE_CLIENT_ID"] != "xxx" &&
     ENV["GOOGLE_CLIENT_SECRET"].present? && ENV["GOOGLE_CLIENT_SECRET"] != "xxx"
    provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"]
  end

  if ENV["FACEBOOK_APP_ID"].present? && ENV["FACEBOOK_APP_ID"] != "xxx" &&
     ENV["FACEBOOK_APP_SECRET"].present? && ENV["FACEBOOK_APP_SECRET"] != "xxx"
    provider :facebook, ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"]
  end

  if ENV["GITHUB_CLIENT_ID"].present? && ENV["GITHUB_CLIENT_ID"] != "xxx" &&
     ENV["GITHUB_CLIENT_SECRET"].present? && ENV["GITHUB_CLIENT_SECRET"] != "xxx"
    provider :github, ENV["GITHUB_CLIENT_ID"], ENV["GITHUB_CLIENT_SECRET"]
  end

  if ENV["LINKEDIN_CLIENT_ID"].present? && ENV["LINKEDIN_CLIENT_ID"] != "xxx" &&
     ENV["LINKEDIN_CLIENT_SECRET"].present? && ENV["LINKEDIN_CLIENT_SECRET"] != "xxx"
    provider :linkedin, ENV["LINKEDIN_CLIENT_ID"], ENV["LINKEDIN_CLIENT_SECRET"]
  end

  if ENV["APPLE_CLIENT_ID"].present? && ENV["APPLE_CLIENT_ID"] != "xxx" &&
     ENV["APPLE_CLIENT_SECRET"].present? && ENV["APPLE_CLIENT_SECRET"] != "xxx"
    provider :apple, ENV["APPLE_CLIENT_ID"], ENV["APPLE_CLIENT_SECRET"], scope: "email name", client_options: { site: "https://appleid.apple.com", authorize_url: "https://appleid.apple.com/auth/authorize", token_url: "https://appleid.apple.com/auth/token" }
  end
end
