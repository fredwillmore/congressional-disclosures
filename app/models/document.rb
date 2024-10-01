class Document < ApplicationRecord
  belongs_to :disclosure

  scope :good, -> { where.not(external_id: ids_with_issues) }
  scope :not_good, -> { where(external_id: ids_with_issues) }

  # TODO: address these issues eventually. I think the majority might just be an issue with transactions_header_regex
  def ids_with_issues
    [
      "10010275",
      "10010412",
      "10010412",
      "10058974",
      "10016774",
      "10040761",
      "10015486",
      "10021225",
      "10026542",
      "10035501",
      "10046177",
      "10048922"
    ]
  end

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
