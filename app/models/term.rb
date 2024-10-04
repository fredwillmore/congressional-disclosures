class Term < ApplicationRecord
  belongs_to :legislator
  belongs_to :state
  belongs_to :congress

  validates :legislator_id, :state, :start_year, presence: true
  validates :start_year, numericality: { other_than: 0 }

  def to_s
    "#{legislator.name} - #{state.name} - #{district} - #{member_type} - #{start_year}-#{end_year}"
  end

  scope :chamber, ->(member_type:, congress: nil) {
    query = where(member_type: member_type)

    congress ? query.where(congress: congress) : query
  }
  scope :house, ->(congress: nil) { chamber(member_type: "Representative", congress: congress) }
  scope :senate, ->(congress: nil) { chamber(member_type: "Senator", congress: congress) }

  def self.by_state_district_year(state, district, year)
    where(
      state: state,
      district: district
    ).where(
      "start_year <= ? AND (end_year >= ? OR end_year IS NULL)", year, year
    )
  end

  def self.congresses
    distinct
      .pluck(:congress, :start_year, :end_year)
      .sort_by(&:first)
      .reverse
      .map do |congress, start_year, end_year|
        {
          congress: congress,
          start_year: start_year,
          end_year: end_year
        }
      end
  end
end
