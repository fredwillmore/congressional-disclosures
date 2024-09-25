class FilingType < ApplicationRecord
  scope :with_text_documents, -> { original_fd }
  scope :original_fd, -> { where(abbreviation: ["O"]) }

  def document_directory
    abbreviation == 'P' ? "ptr-pdfs" : "financial-pdfs"
  end
end
