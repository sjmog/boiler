require "rails_helper"

RSpec.describe "Health Check", type: :request do
  describe "GET /up" do
    it "returns a success response" do
      get "/up"
      expect(response).to have_http_status(:success)
      expect(response.body).to eq("OK")
    end
  end
end
