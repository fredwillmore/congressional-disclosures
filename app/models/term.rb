class Term < ApplicationRecord
  belongs_to :legislator
  belongs_to :state

  validates :legislator_id, :state, :start_year, presence: true
  validates :start_year, numericality: { other_than: 0 }

  def to_s
    "#{legislator.name} - #{state.name} - #{district} - #{member_type} - #{start_year}-#{end_year}"
  end

  def self.by_state_district_year(state, district, year)
    where(
      state: state,
      district: district
    ).where(
      "start_year <= ? AND (end_year >= ? OR end_year IS NULL)", year, year
    )
  end
end
