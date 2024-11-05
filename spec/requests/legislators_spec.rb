require 'rails_helper'

describe "Legislators" do
  let!(:legislator) { create(:legislator, id: 123) }
  let(:term) { create(:term) }
  let(:congress) { create(:congress) }
  let(:state) { create(:state) }

  describe "GET /show" do
    it "returns http success" do
      get  legislator_path(123)

      expect(response).to have_http_status(:success)
    end
  end

end
