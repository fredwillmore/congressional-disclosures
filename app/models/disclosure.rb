require 'http'
require 'json'

class Disclosure < ApplicationRecord

  belongs_to :legislator
  belongs_to :filing_type
  belongs_to :state

  has_many :assets
  has_many :transactions

  validates :legislator, :filing_type, presence: true

  scope :with_text_documents, -> { where(filing_type: FilingType.with_text_documents).where.not(document_text: [nil, '']) }
  scope :original_fd, -> { where(filing_type: FilingType.original_fd) }

  def to_s
    "id: #{id}, document_path: #{document_path}, document_url: #{document_url}"
  end

  def document_url
    "https://disclosures-clerk.house.gov/public_disc/#{filing_type.document_directory}/#{year}/#{document_id}.pdf"
  end

  def document_path
    "db/seeds/data/disclosures/#{filing_type.document_directory}/#{document_id}.pdf"
  end

  def assets_header_regex
    [
      /asset\s*owner\s*value of asset\s*income\s*type\(s\)\s*income\s*tx\.\s*\>\s*\$1..00\?/mi,
      /asset\s*owner\s*value of asset\s*income\s*income\s*tx\.\s*\>\s*type\(s\)\s*\$1..00\?/mi
    ].find { |pattern| assets_text.match?(pattern) }
  end

  def transactions_header_regex
    [
      /asset\s*owner\s*date\s*tx.\s*amount\s*cap\.\s*type\s*gains\s*\>\s*\$2..\?\s*/mi,
    ].find { |pattern| transactions_text.match?(pattern) }
  end

  def assets_text_pages
    assets_text.split(assets_header_regex).reject(&:empty?)
  end
  
  def assets_text
    document_text[/A:\s*(A|SSetS).*?\n(.*)\n.*B:\s*(T|ransaction)/im, 2].strip
  rescue StandardError => e
    debugger
  end

  def transactions_text_pages
    transactions_text.split(transactions_header_regex).reject(&:empty?)
  end

  def transactions_text
    document_text[/B:\s*(T|ransaction).*?\n(.*)\n.*C:\s*(e|rned)/im, 2].strip
  rescue StandardError => e
    debugger
  end

  def json_path
    "db/seeds/data/disclosures/json_files/#{document_id}.json"
  end

  def transactions_prompt(things)
    %Q(
      #{filing_type.transactions_prompt}
      #{things}
    )
  end

  def assets_prompt(things)
    %Q(
      #{filing_type.assets_prompt}
      #{things}
    )
  end

  def extract_assets_json_portion(things)
    # prompt = assets_prompt(things)
    payload = {
      model: "gpt-4o-mini", # or "gpt-3.5-turbo"
      # model: "gpt-3.5-turbo",
      messages: [
        { role: "system", content: "You are a helpful assistant." },
        { role: "user", content: assets_prompt(things) }
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
      json = structured_json.match(/```json\n(.*)\n```/m)[1]
    else
      json = structured_json
    end

    return JSON::parse(json)
  rescue StandardError => e
    debugger
    puts "probably a limit error: #{response.body.to_s}
      check the document at #{document_path}"
    return # just return without doing anything - try again later
  end

  def extract_assets_json
    pages = 10
    assets = assets_text_pages.each_slice(pages).map do |slice|
      extract_assets_json_portion slice.join("\n\n").strip
    end
    return assets
  end

  def extract_transactions_json_portion(things)
    payload = {
      model: "gpt-4o-mini", # or "gpt-3.5-turbo"
      # model: "gpt-3.5-turbo",
      messages: [
        { role: "system", content: "You are a helpful assistant." },
        { role: "user", content: transactions_prompt(things) }
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
      json = structured_json.match(/```json\n(.*)\n```/m)[1]
    else
      json = structured_json
    end

    return JSON::parse(json)
  rescue StandardError => e
    debugger
    puts "probably a limit error: #{response.body.to_s}
      check the document at #{document_path}"
    return # just return without doing anything - try again later
  end

  def extract_transactions_json
    pages = 10
    transactions = transactions_text_pages.each_slice(pages).map do |slice|
      extract_transactions_json_portion slice.join("\n\n").strip
    end
    return transactions
  end

  def extract_filer_information_json
    filer_information = document_text[/Clerk of the House of Representatives.*?20515(.*)A:\s*(A|SSetS)/im, 1].strip

    # Define the prompt
    prompt = %Q(
      #{filing_type.filer_information_prompt}
      #{filer_information}
    )

    # Create the request payload
    payload = {
      model: "gpt-4o-mini", # or "gpt-3.5-turbo"
      messages: [
        { role: "system", content: "You are a helpful assistant. Your task is to process text and return a json representation of the text" },
        { role: "user", content: prompt }
      ],
      max_tokens: 10000
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
      json = structured_json.match(/```json\n(.*)\n```/m)[1]
    else
      json = structured_json
    end

    JSON::parse(json)
  end

  def extract_json
    result = json_text || {}
    
    result.merge! "a_assets" => extract_assets_json
    result.merge! "b_transactions" => extract_transactions_json
    result.merge! extract_filer_information_json
    update(json_text: result)

  rescue StandardError => e
    debugger
    puts "probably a limit error: #{response.body.to_s}
      check the document at #{document_path}"
    return # just return without doing anything - try again later
  end

  def extract_text_from_image
    images = MiniMagick::Image.read(File.open(document_path)).format("png", 0)
    image_path = 'tmp/page.png'
    images.write(image_path)
    extracted_text = RTesseract.new(image_path).to_s # Extracted text
    debugger
    puts extracted_text
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

  def api_key
    ENV.fetch('OPENAI_API_KEY')
  end
end
