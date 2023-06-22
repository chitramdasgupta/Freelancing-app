require 'rails_helper'

RSpec.describe "Notifications", type: :request do
  describe "GET /count" do
    it "returns http success" do
      get "/notifications/count"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /fetch_notifications" do
    it "returns http success" do
      get "/notifications/fetch_notifications"
      expect(response).to have_http_status(:success)
    end
  end

end