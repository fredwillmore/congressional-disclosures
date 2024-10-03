FactoryBot.define do
  factory :congress do
    
  end

  factory :document do
    
  end

  factory :income_type do
    
  end

  factory :asset do
  end

  factory :disclosure do
    legislator
    filing_type
    state
  end

  factory :filing_type do
  end

  factory :legislator do
    first_name { "Test" }
    last_name { "Test" }
    bioguide_id { "ABC123" }
    birth_year { 1977 }
  end

  factory :state do
    abbreviation {"IL"}
    name {"Illinois"}
  end

  factory :transaction do
  end
end
