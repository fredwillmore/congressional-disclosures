# spec/controllers/home_controller_spec.rb
require 'rails_helper'

describe "Home" do
  describe 'POST #congress' do
    context 'when making a valid POST request' do
      it 'routes to the congress action' do
        post "/congress", params: { congress_number: 118 }, as: :turbo_stream
        expect(response).to have_http_status(:success)
      end

      it "renders a template with variables" do
        state_info = instance_double(Array)
        allow(State).to receive(:congress_info).and_return state_info
        congress = create(:congress, id: 123)

        turbo_stream_buffer = instance_double ActiveSupport::SafeBuffer
        expect_any_instance_of(Turbo::Streams::TagBuilder)
          .to receive(:replace)
          .with(:congress_turbo_frame, partial: "congress", locals: {state_info: state_info, congress: congress})
          .and_return(turbo_stream_buffer)
        expect_any_instance_of(HomeController).to receive(:render).with(turbo_stream: turbo_stream_buffer)
          
        post "/congress", params: { congress: 123 }, as: :turbo_stream
      end
    end
  end
end
