class Transaction < ApplicationRecord
  belongs_to :disclosure

  enum owner: {
    owner_jt: "JT",
    owner_sp: "SP",
    owner_dc: "DC"
  }

  enum amount: {
    amount_none: 'None',
    amount_range_1: "$1 - $1,000",
    amount_range_2: '$1,001 - $15,000',
    amount_range_3: '$15,001 - $50,000',
    amount_range_4: '$50,001 - $100,000',
    amount_range_5: '$100,001 - $250,000',
    amount_range_6: '$250,001 - $500,000',
    amount_range_7: '$500,001 - $1,000,000',
    amount_range_8: "$1,000,001 - $5,000,000",
    amount_range_9: "Spouse/DC Over $1,000,000",
    amount_range_10: '$1,000,001 - $5,000,000',
    amount_range_11: '$5,000,001 - $25,000,000',
    amount_range_12: '$25,000,001 - $50,000,000',
    amount_range_13: '$50,000,001 - $100,000,000'
  }

  enum transaction_type: {
    transaction_type_p: "P",
    transaction_type_s: "S",
    transaction_type_sp: "S (partial)"
  }

  def to_s
    "date: #{date}, asset: #{asset}, owner: #{owner}, amount: #{amount}, transaction_type: #{transaction_type}, cap_gains_over_200: #{cap_gains_over_200}"
  end
end
