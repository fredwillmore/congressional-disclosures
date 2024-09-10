require 'rails_helper'

RSpec.describe Disclosure, type: :model do
  describe :extract_text do
    let(:document_path) do
      'spec/fixtures/files/disclosure_documents/10059371.pdf'
    end
    let(:filing_type) do
      create(
        :filing_type,
        abbreviation: 'O',
        name: 'Original FD'
      )
    end
    let(:disclosure) do
      create(
        :disclosure,
        filing_type: filing_type,
      )
    end

    before do
      allow(disclosure).to receive(:document_path).and_return(document_path)
    end

    it "has UTF-8 encoding" do
      disclosure.extract_text
      expect(disclosure.document_text.encoding.name).to eq "UTF-8"
    end
  end

  describe :extract_json do
    let(:document_text) do
      File.read('spec/fixtures/files/disclosure_documents/document_text.txt')
      # File.read('spec/fixtures/files/disclosure_documents/document_text_10061324.txt')
    end
    let(:filing_type) do
      create(
        :filing_type,
        abbreviation: 'O',
        name: 'Original FD'
      )
    end
    let(:disclosure) do
      create(
        :disclosure,
        filing_type: filing_type,
        document_text: document_text
      )
    end
    it "does the Right Thing" do
      disclosure.extract_json
    end
  end

end
