require 'rails_helper'

describe Disclosure do
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

  describe :transactions_text do
    let(:disclosure) { create(:disclosure, document_text: document_text)}
    let(:document_text) { File.read(document_text_file) }
    let(:expected_text) { File.read(expected_text_file) }
  
    context "with huge file" do
      let(:document_text_file) { 'spec/fixtures/files/disclosure_documents/10010412.txt' }
      let(:expected_text_file) { 'spec/fixtures/files/disclosure_documents/transactions_section_10010412.txt' }

      it "matches the expected text" do
        expect(disclosure.transactions_text).to eq(expected_text)
      end
    end
    
    context "with 2013 filing" do
      let(:document_text_file) { 'spec/fixtures/files/disclosure_documents/10000804.txt' }
      let(:expected_text_file) { 'spec/fixtures/files/disclosure_documents/transactions_section_10000804.txt' }

      it "gives the expected value" do
        expect(disclosure.transactions_text).to eq expected_text
      end
    end

    context "with 2023 filing" do
      let(:document_text_file) { 'spec/fixtures/files/disclosure_documents/10059772.txt' }
      let(:expected_text_file) { 'spec/fixtures/files/disclosure_documents/transactions_section_10059772.txt' }

      it "gives the expected value" do
        expect(disclosure.transactions_text).to eq expected_text
      end
    end
  end

  describe :transactions_text_pages do
    let(:disclosure) { create(:disclosure, document_text: document_text)}
    let(:document_text) { File.read(document_text_file) }
    let(:expected_text) { File.read(expected_text_file) }

    context "with 2013 filing" do
      let(:document_text_file) { 'spec/fixtures/files/disclosure_documents/10000804.txt' }
      let(:expected_text_file) { 'spec/fixtures/files/disclosure_documents/expected_transactions_page_1_10000804.txt' }

      it "works right" do
        expect(disclosure.transactions_text_pages[0]).to eq expected_text
      end
    end
  end

  xdescribe :extract_transactions_json do
    let(:disclosure) { create(:disclosure, document_text:)}
    let(:disclosure) { create(:disclosure, document_text: document_text)}
    let(:document_text) { File.read document_text_file }

    context "with huge file" do
      let(:document_text_file) { 'spec/fixtures/files/disclosure_documents/10010412.txt' }

      # this is for testing interactions with the openai api, don't run every time
      xit "doesn't raise errors" do
        expect { disclosure.extract_transactions_json }.not_to raise_error
      end
    end

    context "with 2013 filing" do
      let(:document_text_file) { 'spec/fixtures/files/disclosure_documents/10000804.txt' }

      xit "doesn't raise errors" do
        expect { disclosure.extract_transactions_json }.not_to raise_error
      end
    end

    context "with 2023 filing" do
      let(:document_text_file) { 'spec/fixtures/files/disclosure_documents/10060415.txt' }

      xit "doesn't raise errors" do
        expect { disclosure.extract_transactions_json }.not_to raise_error
      end
    end
  end

  xdescribe :extract_filer_information_json do
    let(:disclosure) { create(:disclosure, document_text:)}
    let(:disclosure) { create(:disclosure, document_text: document_text)}
    let(:document_text) { File.read document_text_file }

    context "with huge file" do
      let(:document_text_file) { 'spec/fixtures/files/disclosure_documents/10010412.txt' }

      # this is for testing interactions with the openai api, don't run every time
      xit "doesn't raise errors" do
        expect { disclosure.extract_filer_information_json }.not_to raise_error
      end
    end

    context "with 2013 filing" do
      let(:document_text_file) { 'spec/fixtures/files/disclosure_documents/10000804.txt' }

      xit "doesn't raise errors" do
        expect { disclosure.extract_filer_information_json }.not_to raise_error
      end
    end

    context "with 2023 filing" do
      let(:document_text_file) { 'spec/fixtures/files/disclosure_documents/10060415.txt' }

      xit "doesn't raise errors" do
        expect { disclosure.extract_filer_information_json }.not_to raise_error
      end
    end
  end

  describe :assets_text_pages do
    let(:disclosure) { create(:disclosure, document_text: document_text)}

    context "with 2013 filing" do
      let(:document_text) do
        File.read('spec/fixtures/files/disclosure_documents/10000804.txt')
      end
      let(:expected_assets_pages) do
        # TODO: need to rename this text file so that it's clear that it is the result of splitting
        # the text into pages on the page header and then joining on newlines to form a contiguous 
        # piece of text without the page headers interspersed
        File.read('spec/fixtures/files/disclosure_documents/expected_assets_text_10000804.txt')
      end

      it "works right" do
        expect(disclosure.assets_text_pages.join("\n").strip).to eq expected_assets_pages
      end
    end
  end

  describe :assets_text do
    let(:disclosure) { create(:disclosure, document_text: document_text)}
    
    context "with huge file" do
      let(:document_text) do
        File.read('spec/fixtures/files/disclosure_documents/10010412.txt')
      end

      it "works right" do
        expect { disclosure.assets_text }.not_to raise_error
      end
    end
    
    context "with 2023 filing" do
      let(:document_text) do
        File.read('spec/fixtures/files/disclosure_documents/10059772.txt')
      end
      let(:expected_assets_text) do
        File.read('spec/fixtures/files/disclosure_documents/expected_assets_text_10059772.txt')
      end

      it "gives the expected value" do
        expect(disclosure.assets_text).to eq expected_assets_text        
      end
    end
  end

  xdescribe :extract_assets_json do
    let(:disclosure) { create(:disclosure)}
    let(:assets_text) { '' }

    before do
      allow(disclosure).to receive(:assets_text).and_return(assets_text)
    end

    context "with page of data" do
      let(:assets_text) do
        File.read('spec/fixtures/files/disclosure_documents/page_of_data.txt')
      end

      it "doesn't raise errors" do
        expect { disclosure.extract_assets_json }.not_to raise_error
      end
    end

    context "with huge file" do
      let(:assets_text) do
        File.read('spec/fixtures/files/disclosure_documents/10010412.txt')
      end

      it "doesn't raise errors" do
        expect { disclosure.extract_assets_json }.not_to raise_error
      end
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
      # instance_double Disclosure
    end

    it "calls the extract functions" do
      expect(disclosure).to receive(:extract_assets_json).and_return([])
      expect(disclosure).to receive(:extract_transactions_json).and_return([])
      expect(disclosure).to receive(:extract_filer_information_json).and_return({})
      expect(disclosure).to receive(:extract_json).and_call_original
      disclosure.extract_json
    end
  end

end
