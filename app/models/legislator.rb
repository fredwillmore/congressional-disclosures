class Legislator < ApplicationRecord

  validates :first_name, :last_name, :bioguide_id, presence: true
  validates :birth_year, numericality: { other_than: 0 }

  def to_s
    "first_name: #{first_name}, last_name: #{last_name}, bioguide_id: #{bioguide_id}"
  end
end
