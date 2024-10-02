# spec/controllers/home_controller_spec.rb
require 'rails_helper'

describe HomeController do
  describe 'POST #congress' do
    context 'when making a valid POST request' do
      it 'routes to the congress action' do
        # You can simulate a POST request like this:
        post :congress, params: { congress_number: 118 }

        # Check that the response was successful
        expect(response).to be_successful

        # Optionally, you can check the HTTP status code (e.g., 200 OK, 302 for redirect, etc.)
        expect(response.status).to eq(200)
      end
    end
  end
end
