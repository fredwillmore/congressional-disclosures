require 'rails_helper'

describe State do
  let!(:state) { create :state, name: "Oregon", abbreviation: "OR" }

  describe "self.congress_info" do
    it "calls congress_info on each state" do
      expect_any_instance_of(State).to receive(:congress_info).with(congress_number: 123)
      State.congress_info(congress_number: 123)
    end
  end

  describe "congress_info" do
    it "gets the info" do
      congress_info = state.congress_info(congress_number: 123)
      expect(congress_info.state).to eq state
      expect(congress_info.name).to eq "Oregon"
      expect(congress_info                                                                                                                                                                                                                                                                                                                                                                         .abbreviation).to eq "OR"
    end
  end
end
