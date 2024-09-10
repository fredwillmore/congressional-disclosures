class FilingType < ApplicationRecord
  scope :with_text_documents, -> { original_fd }
  scope :original_fd, -> { where(abbreviation: ["O"]) }

  def document_directory
    abbreviation == 'P' ? "ptr-pdfs" : "financial-pdfs"
  end

  def assets_prompt
    case abbreviation
    when 'A'
      %Q(
        )
    when 'O'
      %Q(
        Please convert the following text into a structured JSON format.
        The JSON should be an array of arrays representing assets with array entries: asset, owner, value, income_type, income_current_year, income_preceding_year, tax_over_1000
        The array can be empty if the text is something like "none"
        Please return a complete JSON array of all hashes, without omitting any entries or adding comments.
        here is the text:
      )
    else
    end
  end

  def transactions_prompt
    case abbreviation
    when 'A'
      %Q(
        )
    when 'O'
      %Q(
        Please convert the following text into a structured JSON format.
        The JSON should be an array of arrays representing transactions with array entries: asset, owner, date, transaction_type, amount, cap_gains_over_200
        The array can be empty if the text is something like "none"
        Please return a complete JSON array of all hashes, without omitting any entries or adding comments.
        here is the text:
      )
    else
    end
  end

  def remaining_info_prompt
    case abbreviation
    when 'A'
      %Q(
        )
    when 'O'
      %Q(
        Please convert the following text into a structured JSON format.
        The JSON should be a hash with keys filer_information, filing_information, c_earned_income, d_liabilities, e_positions, f_agreements, g_gifts, h_travel, i_charity
        c_earned_income: array of hashes with keys source, type, amount_current_year, amount_preceding_year
        d_liabilities: array of hashes with keys owner, creditor, date_incurred, type, amount
        e_positions: array of hashes with keys postion, organization_name
        f_agreements: array
        g_gifts: array
        h_travel: array of hashes with keys trip_details, inclusions
          trip_details - hash with keys source, start_date, end_date, itinerary, days_at_own_expense;
          inclusions - hash with keys lodging, food, family
        i_charity: array
        the hashes or arrays can be empty if the text is something like "none"
        Please return a complete JSON array of all hashes, without omitting any entries or adding comments.
        here is the text:
      )
    else
    end
  end
end
