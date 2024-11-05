class Asset < ApplicationRecord
  belongs_to :disclosure
  has_and_belongs_to_many :income_types
  # belongs_to :asset_value

  validates :asset_value, presence: true

  enum owner: {
    owner_jt: "JT",
    owner_sp: "SP",
    owner_dc: "DC"
  }

  enum asset_value: {
    asset_value_none: 'None',
    asset_value_range_1: "$1 - $1,000",
    asset_value_range_2: '$1,001 - $15,000',
    asset_value_range_3: '$15,001 - $50,000',
    asset_value_range_4: '$50,001 - $100,000',
    asset_value_range_5: '$100,001 - $250,000',
    asset_value_range_6: '$250,001 - $500,000',
    asset_value_range_7: '$500,001 - $1,000,000',
    asset_value__range_8: "$1,000,001 - $5,000,000",
    asset_value__range_9: "Spouse/DC Over $1,000,000"
    # asset_value_range_7: '$1,000,001 - $5,000,000',
    # asset_value_range_8: '$5,000,001 - $25,000,000',
    # asset_value_range_9: '$25,000,001 - $50,000,000',
    # asset_value_range_10: '$50,000,001 - $100,000,000'
  }

  enum income: {
    income_none: "None",
    income_range_1: "$1 - $200",
    income_range_2: "$201 - $1,000",
    income_range_3: "$1,001 - $2,500",
    income_range_4: "$2,501 - $5,000",
    income_range_5: "$5,001 - $15,000",
    income_range_6: '$15,001 - $50,000',
    income_range_7: "$50,001 - $100,000",
    income_range_8: "$100,001 - $1,000,000",
    income_range_9: "$1,000,001 - $5,000,000",
    income_range_10: "Spouse/DC Over $1,000,000"
  }

  # enum income_type: {
  #   income_type_none: 'None',
  #   income_type_book_royalty: "Book Royalty",
  #   income_type_capital_gains: 'Capital Gains',
  #   income_type_dividends: 'Dividends',
  #   income_type_interest: 'Interest',
  #   income_type_partnership_income: 'Partnership Income',
  #   income_type_rent: 'Rent',
  #   # income_type_royalties: 'Royalties',
  #   income_type_spouse_salary: ' Spouse Salary',
  # }

  def to_s
    "asset: #{asset}, owner: #{owner}, value: #{asset_value}, income: #{income}, income_types: #{income_types.map(&:name)}"
  end
end
