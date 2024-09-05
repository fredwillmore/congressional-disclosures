class Term < ApplicationRecord
  belongs_to :legislator
  belongs_to :state

  validates :legislator_id, :state, :start_year, presence: true
  validates :start_year, numericality: { other_than: 0 }

  def to_s
    "#{legislator.name} - #{state.name} - #{member_type} - #{start_year}-#{end_year}"
  end
end
