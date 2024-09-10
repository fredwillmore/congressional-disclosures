class Legislator < ApplicationRecord

  validates :first_name, :last_name, :bioguide_id, presence: true
  validates :birth_year, numericality: { other_than: 0 }

  has_many :terms

  def to_s
    "first_name: #{first_name}, last_name: #{last_name}, bioguide_id: #{bioguide_id}"
  end

  def name
    [prefix, first_name, last_name, suffix].compact.join ' '
  end
end
