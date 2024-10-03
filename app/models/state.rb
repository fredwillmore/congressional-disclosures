class State < ApplicationRecord
  has_many :terms

  def self.congress_info(congress_number: )
    all.map { |state| state.congress_info congress_number: congress_number }    
  end

  def congress_info(congress_number: )
    OpenStruct.new(
      {
        state: self,
        name: name,
        abbreviation: abbreviation,
        house: terms.house(congress: congress_number).joins(:legislator).order('legislators.last_name').map(&:legislator),
        senate: terms.senate(congress: congress_number).joins(:legislator).order('legislators.last_name').map(&:legislator)
      }
    )
  end

end
