require 'rails_helper'

describe GptRequest do
  describe "get_json_response" do
    it "fetches the json response and returns the parsed object" do
      gpt_request = GptRequest.new(request_type: 'test', content: 'test', page: 1, document_external_id: "12345")
      # response = HTTP.headers(headers).post(endpoint, body: request.payload)
      http_client = instance_double(HTTP::Client)
      http_response = instance_double(HTTP::Response)
      allow(http_response).to receive(:body).and_return(
        {
          "choices" => [
            {
              "message" => {
                "content" => "[\"http response json content\"]"
              }

            }
          ]
        }.to_json
      )
      allow(HTTP).to receive(:headers).and_return(http_client)
      allow(http_client).to receive(:post).with(anything, {body: a_string_matching(/You are a helpful assistant/)}).at_least(:once).and_return(http_response)

      expect(gpt_request.get_json_response).to eq (["http response json content"])
    end
  end
end

