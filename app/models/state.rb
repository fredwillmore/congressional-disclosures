class State < ApplicationRecord
  has_many :terms

  def self.congress_info(congress: )
    all.map { |state| state.congress_info congress: congress }    
  end

  def congress_info(congress: )
    OpenStruct.new(
      {
        state: self,
        name: name,
        abbreviation: abbreviation,
        house: terms.house(congress: congress).joins(:legislator).order('legislators.last_name').map(&:legislator),
        senate: terms.senate(congress: congress).joins(:legislator).order('legislators.last_name').map(&:legislator)
      }
    )
  end

end
