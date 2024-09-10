require 'http'
require 'json'

class Disclosure < ApplicationRecord

  belongs_to :legislator
  belongs_to :filing_type
  belongs_to :state

  validates :legislator, :filing_type, presence: true

  scope :with_text_documents, -> { where(filing_type: FilingType.with_text_documents).where.not(document_text: [nil, '']) }
  scope :original_fd, -> { where(filing_type: FilingType.original_fd) }

  def document_url
    "https://disclosures-clerk.house.gov/public_disc/#{filing_type.document_directory}/#{year}/#{document_id}.pdf"
  end

  def document_path
    "db/seeds/data/disclosures/#{filing_type.document_directory}/#{document_id}.pdf"
  end

  def json_path
    "db/seeds/data/disclosures/json_files/#{document_id}.json"
  end

  def extract_json
    result = json_text || {}
    
    # Replace with your OpenAI API key
    api_key = ENV.fetch('OPENAI_API_KEY')
    
    [:assets_prompt, :transactions_prompt, :remaining_info_prompt].each do |filing_type_prompt|
      # Define the prompt
      prompt = %Q(
        #{filing_type.send filing_type_prompt}
        #{document_text}
      )
      # identifying all fields:\n\n#{document_text}"
      # prompt = "Hello, can you respond?"
      
      # Create the request payload
      payload = {
        model: "gpt-4o-mini", # or "gpt-3.5-turbo"
        # model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: "You are a helpful assistant." },
          { role: "user", content: prompt }
        ],
        max_tokens: 14000
      }.to_json

      headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{api_key}"
      }

      endpoint = "https://api.openai.com/v1/chat/completions"
      # Make the HTTP POST request to the OpenAI API
      response = HTTP.headers(headers).post(endpoint, body: payload)
      response_body = response.body
      # Parse the response and extract the JSON content
      structured_json = JSON.parse(response_body)["choices"][0]["message"]["content"]
      
      if structured_json.match(/```json\n(.*)\n```/m)
        things = structured_json.match(/```json\n(.*)\n```/m)[1]
      else
        things = structured_json
      end

      case filing_type_prompt
      when :assets_prompt
        result.merge! "a_assets" => JSON::parse(things)
      when :transactions_prompt
        result.merge! "b_transactions" =>JSON::parse(things)
      else # remaining info
        result.merge! JSON::parse(things)
      end
    rescue StandardError => e
      # debugger
      return # just return without doing anything - try again later
    end

    update(json_text: result)
  end

  def extract_text
    return unless File.exist?(document_path)
    return if document_text.present?

    extracted_text = PDF::Reader.new(document_path).pages.map do |page|
      page.text.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
    end.map(&:presence).compact.join("\n")
    extracted_text.delete!("\0") # delete null character
    # puts "This is the text, see: #{extracted_text}"
    update(
      document_text: extracted_text,
      image_pdf: false
    )
  rescue ArgumentError, Encoding::CompatibilityError => e
    if document_id.in? ['20005968']
      puts "CompatibilityError - skipping #{document_id} and hoping it isn't any worse"
    else
      puts "uh oh more trouble #{document_id}"
      debugger
    end
  rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError, PDF::Reader::EncryptedPDFError
    puts "This file is a rasterized image file - I don't have high hopes for the quality"
    images = MiniMagick::Image.read(File.open(document_path)).format("png", 0)
    image_path = 'tmp/page.png'
    images.write(image_path)
    extracted_text = RTesseract.new(image_path).to_s # Extracted text

    puts "This is the text, see: #{extracted_text}"
    update(
      document_text: extracted_text,
      image_pdf: true
    )
  end

  def fetch_document
    return if File.exist?(document_path)

    URI.open(document_url) do |file|
      File.open(document_path, 'wb') do |output|
        output.write(file.read)
      end
    end
  rescue
    puts "error fetching #{document_path}"
  end
end
