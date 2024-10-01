require 'http'
require 'json'

class Disclosure < ApplicationRecord

  belongs_to :legislator
  belongs_to :filing_type
  belongs_to :state

  has_one :document

  has_many :assets
  has_many :transactions

  validates :legislator, :filing_type, presence: true

  scope :with_text_documents, -> { where(filing_type: FilingType.with_text_documents).joins(:document).where.not(document: {document_json: [nil, '']}) }
  scope :original_fd, -> { where(filing_type: FilingType.original_fd) }

  # using request_accumulator to inject different handling of batch requests
  # need to refactor so it's not as clunky :/
  attr_accessor :request_accumulator

  def to_s
    "id: #{id}, document_path: #{document_path}, document_url: #{document_url}"
  end

  def document_url
    document.document_url
  end
  
  def document_path
    document.document_path
  end

  def assets_header_regex
    [
      /asset\s*owner\s*value of asset\s*income\s*type\(s\)\s*income\s*tx\.\s*\>\s*\$1..00\?/mi,
      /asset\s*owner\s*value of asset\s*income\s*(?:income)?\s*tx\.\s*\>\s*type\(s\)\s*\$1..00\?\s*(?:income)?\s*/mi
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
    document_text[/B:\s*(t|t?ransaction).*?\n(.*)\n.*C:\s*(e|a?rn)/im, 2].strip
  rescue StandardError => e
    debugger
  end

  def document_id
    document&.external_id
  end

  def json_text
    document&.document_json
  end

  delegate(
    :json_path, :document_text,
    to: :document, allow_nil: true
  )

  # def json_path
  #   document.json_path
  # end

  def import_json_text_from_file
    if File::file?(json_path)
      update(json_text: JSON::parse(File.read(json_path)))
    end
  end

  def document_text_path
    document.document_text_path
  end

  def import_document_text_from_file
    if File.file?(document_text_path)
      update(document_text: File.read(document_text_path))
    end
  end

  def export_document_text_to_file
    File.write(document_text_path, document_text)
  end

  # def transactions_prompt(things)
  #   %Q(
  #     #{filing_type.transactions_prompt}
  #     #{things}
  #   )
  # end

  # def assets_prompt(things)
  #   %Q(
  #     #{filing_type.assets_prompt}
  #     #{things}
  #   )
  # end

  # def assets_prompt_messages(things)
  #   [
  #     { role: "system", content: "You are a helpful assistant. Your task is to process text and return a valid json object." },
  #     { role: "user", content: assets_prompt(things) }
  #   ]
  # end

  def extract_assets_json_portion(things, page)
    request = GptRequest.new(request_type: :asset, content: things, page: page, document_external_id: document.external_id)

    if request_accumulator
      request_accumulator << request
      return []
    end

    request.get_json_response
  rescue StandardError => e
    puts "probably a limit error: #{response.body.to_s}
      check the document at #{document_path}"
    return # just return without doing anything - try again later
  end

  def extract_assets_json
    assets_text_pages.each_slice(assets_pages).map.with_index do |slice, i|
      extract_assets_json_portion slice.join("\n\n").strip, i+1
    end.reduce(:+)
  end

  def extract_transactions_json_portion(things, page)
    request = GptRequest.new(request_type: :transaction, content: things, page: page, document_external_id: document.external_id)

    if request_accumulator
      request_accumulator << request
      return []
    end

    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{api_key}"
    }
    endpoint = "https://api.openai.com/v1/chat/completions"
    # Make the HTTP POST request to the OpenAI API
    
    response = HTTP.headers(headers).post(endpoint, body: request.payload)
    response_body = response.body
    # Parse the response and extract the JSON content
    structured_json = JSON.parse(response_body)["choices"][0]["message"]["content"]
    
    if structured_json.match(/```(?:json)\n(.*)\n```/m)
      json = structured_json.match(/```(?:json)\n(.*)\n```/m)[1]
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
    transactions_text_pages.each_slice(transactions_pages).map.with_index do |slice, i|
      extract_transactions_json_portion slice.join("\n\n").strip, i+1
    end.reduce(:+)
  end

  def filer_information
    document_text[/Clerk of the House of Representatives.*?20515(.*)A:\s*(A|SSetS)/im, 1].strip
  end

  def filer_information_prompt
    %Q(
      #{filing_type.filer_information_prompt}
      #{filer_information}
    )
  end

  def extract_filer_information_json
    request = GptRequest.new(request_type: :filer_information, content: filer_information, page: 1, document_external_id: document.external_id)

    if request_accumulator
      request_accumulator << request
      return {}
    end

    request.get_json_response
  end

  def extract_json
    result = document.document_json || {}
    
    result.merge! "a_assets" => extract_assets_json
    result.merge! "b_transactions" => extract_transactions_json
    result.merge! extract_filer_information_json
    document.update(document_json: result)

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
    # debugger
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
    document&.update(document_text: extracted_text)
    # TODO: is this still being used?
    update(
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

  def gpt_model
    "gpt-4o-mini"
  end

  def max_tokens
    14000
  end

  def assets_pages
    10
  end

  def transactions_pages
    10
  end
end
