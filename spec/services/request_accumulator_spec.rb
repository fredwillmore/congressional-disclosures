require 'rails_helper'

describe RequestAccumulator do
  let(:request_accumulator) { RequestAccumulator.new(file) }
  let(:file) { instance_double File }
  let(:request) { GptRequest.new(request_type: 'test', content: 'test', page: 123, document_external_id: 321) }

  describe "<<" do
    it "puts request onto requests array" do
      expect { request_accumulator << request }.to change(request_accumulator.requests, :count).by(1)
    end
  end

  xdescribe "send_requests" do
    it "sends the requests" do
      request_accumulator.send_requests
      
      # expect(file).to receive(:<<).with(request)
    end
  end
end