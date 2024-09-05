class PartyAffiliation < ApplicationRecord
  validates :legislator_id, :party_id, :start_year, presence: true
  validates :start_year, numericality: { other_than: 0 }

  belongs_to :party
  belongs_to :legislator

  def to_s
    "#{legislator.name} - #{party.name} #{start_year}-#{end_year}"
  end
end
