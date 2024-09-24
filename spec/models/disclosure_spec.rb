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

  describe :extract_transactions_json do
    let(:disclosure) do
      create(:disclosure, document_text: document_text).tap do |d|
        d.request_accumulator = request_accumulator
      end
    end
    let(:document_text) { File.read document_text_file }
    let(:request_accumulator) { nil }
    
    context "when using request_accumulator" do
      context "with 2023 filing" do
        let(:document_text_file) { 'spec/fixtures/files/disclosure_documents/10060415.txt' }
        let(:request_batch_file) { instance_double(File) }
        let(:gpt_request) { instance_double(GptRequest) }
        let(:request_accumulator) { RequestAccumulator.new(request_batch_file) }

        it "creates a GptRequest object" do
          allow(GptRequest).to receive(:new).and_return(gpt_request)
          expect(request_accumulator).to receive(:puts).with(gpt_request)

          disclosure.extract_transactions_json
        end

        xit "sends requests to request_batch_file" do
          expect(request_batch_file).to receive(:puts)
          disclosure.extract_transactions_json
        end
      end
    end

    context "when not using request_accumulator" do
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
          expect do
            v = disclosure.extract_transactions_json
            debugger
          end.not_to raise_error
        end
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
        File.read('spec/fixtures/files/disclosure_documents/2013_filing_document_text.txt')
      end
      let(:expected_assets_pages) do
        "### asset text page 1 ###\n\n### asset text page 2 ###"
      end

      it "works right" do
        expect(disclosure.assets_text_pages.join("\n").strip).to eq expected_assets_pages
      end
    end
  end

  describe :assets_text do
    let(:disclosure) { create(:disclosure, document_text: document_text)}

    context "with 2013 filing" do
      let(:document_text) do
        File.read('spec/fixtures/files/disclosure_documents/2013_filing_document_text.txt')
      end
      let(:assets_text) do
        <<~END
          asset                                      owner value of asset income          income    tx. >
                                                                            type(s)                  $1,000?


          ### asset text page 1 ###
          asset                                        owner value of asset income            income    tx. >
                                                                              type(s)                   $1,000?

          ### asset text page 2 ###
        END
      end

      it "works right" do
        expect(disclosure.assets_text).to eq assets_text.strip
      end
    end
    
    context "with 2023 filing" do
      let(:document_text) do
        File.read('spec/fixtures/files/disclosure_documents/2023_filing_document_text.txt')
      end
      let(:assets_text) do
        <<~END
          Asset                                                Owner Value of Asset      Income Type(s) Income        Tx. >
                                                                                                                       $1,000?


          ### asset text page 1 ###
          Asset                                                Owner Value of Asset      Income Type(s) Income        Tx. >

                                                                                                                      $1,000?


          ### asset text page 2 ###
          Asset                                                  Owner Value of Asset       Income Type(s) Income         Tx. >
                                                                                                                          $1,000?

          ### asset text page 3 ###
        END
      end


      it "gives the expected value" do
        expect(disclosure.assets_text).to eq assets_text.strip
      end
    end
  end

  describe :extract_assets_json do
    let(:disclosure) { create(:disclosure)}
    let(:assets_text) { '' }

    before do
      allow(disclosure).to receive(:assets_text).and_return(assets_text)
    end

    context "with page of data" do
      let(:assets_text) do
        File.read('spec/fixtures/files/disclosure_documents/page_of_data.txt')
      end

      it "calls get_json_response on GptRequest" do
        allow_any_instance_of(GptRequest).to receive(:get_json_response).and_return(["http response json content"])

        expect(disclosure.extract_assets_json[0]).to eq( "http response json content")
      end
    end

    xcontext "with huge file" do
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

    # this is a test for examining the gpt response for a single record with different gpt models
    xcontext "with document 10013349" do
      let(:disclosure) { create(:disclosure, document_id: document_id) }
      let(:document_id) { '10013349' }
      let(:max_tokens) { 14000 }
      let(:assets_pages) { 10 }
      let(:transactions_pages) { 10 }
  
      before do
        disclosure.import_document_text_from_file
        allow(disclosure).to receive(:gpt_model).and_return(gpt_model)
        allow(disclosure).to receive(:max_tokens).and_return(max_tokens)
        allow(disclosure).to receive(:assets_pages).and_return(assets_pages)
        allow(disclosure).to receive(:transactions_pages).and_return(transactions_pages)
      end

      context "with gpt-4o-mini" do
        let(:gpt_model) { "gpt-4o-mini" }

        it "works right" do
          result = disclosure.extract_assets_json
          debugger
        end

        it "works right" do
          result = disclosure.extract_transactions_json
          debugger
        end
      end

      context "with gpt-4o" do
        let(:gpt_model) { "gpt-4o" }
        let(:max_tokens) { 4000 }
        let(:assets_pages) { 5 }
        let(:transactions_pages) { 5 }
  
        it "works right" do
          result = disclosure.extract_assets_json
          debugger
        end

        it "works right" do
          result = disclosure.extract_transactions_json
          debugger
        end
      end

      context "with gpt-3.5-turbo-0125" do
        let(:gpt_model) { "gpt-3.5-turbo-0125" }
        let(:max_tokens) { 4000 }
        let(:assets_pages) { 5 }
        let(:transactions_pages) { 5 }
  
        it "works right" do
          result = disclosure.extract_assets_json
          debugger

          it "works right" do
            result = disclosure.extract_transactions_json
            debugger
          end
        end
      end

      context "with gpt-3.5-turbo-0125" do
        let(:gpt_model) { "gpt-3.5-turbo-0125" }
        let(:max_tokens) { 4000 }
        let(:assets_pages) { 5 }
        let(:transactions_pages) { 5 }
  
        it "works right" do
          result = disclosure.extract_assets_json
          debugger

          it "works right" do
            result = disclosure.extract_transactions_json
            debugger
          end
        end
      end
    end
  end

end
