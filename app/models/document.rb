class Document < ApplicationRecord
  belongs_to :disclosure

  def document_url
    "https://disclosures-clerk.house.gov/public_disc/#{disclosure.filing_type.document_directory}/#{disclosure.year}/#{external_id}.pdf"
  end

  def document_path
    "db/seeds/data/disclosures/#{disclosure.filing_type.document_directory}/#{external_id}.pdf"
  end

  def json_path
    "db/seeds/data/disclosures/json_files/#{external_id}.json"
  end

  def document_text_path
    "db/seeds/data/disclosures/text_files/#{external_id}.txt"
  end

end
