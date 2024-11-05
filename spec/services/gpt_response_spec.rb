require 'rails_helper'

describe GptResponse do
  let(:gpt_response) { GptResponse.new(response: response) }
  let(:response) { File.read(response_json_file) }

  context "with filer_information response type" do
    let(:response_json_file) { "spec/fixtures/files/batch_files/responses/document-10054467-filer_information-1.json" }
    
    describe "get_json_response" do
      it "parses the json response and returns the parsed object" do
        expect(gpt_response.get_json_response).to be_a(Hash)
        expect(gpt_response.get_json_response["filer_information"]).to eq( {
          "name"=>"Hon. Patrick T. McHenry",
          "status"=>"Member",
          "state_district"=>"NC10"
        })
      end
    end
  end

  context "with asset response type" do
    let(:response_json_file) { "spec/fixtures/files/batch_files/responses/document-10006394-asset-1.json" }
    
    describe "get_json_response" do
      it "parses the json response and returns the parsed object" do
        expect(gpt_response.get_json_response).to be_a(Enumerable)
        expect(gpt_response.get_json_response[0]).to eq ["Ameriprise SEP IRA ⇒ AllianceBernstein High Income", "SP", "$1,001 - $15,000", "Tax-Deferred", "None"]
        expect(gpt_response.get_json_response.count).to eq 138
      end
    end
    
    describe "page" do
      it "gets the page from the custom_id" do
        expect(gpt_response.page).to eq("1")
      end
    end
    
    describe "response_type" do
      it "gets the response_type from the custom_id" do
        expect(gpt_response.response_type).to eq("asset")
      end
    end
    
    describe "document_id" do
      it "gets the document_id from the custom_id" do
        expect(gpt_response.document_id).to eq("10006394")
      end
    end
  end
end
  
