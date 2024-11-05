class LegislatorsController < ApplicationController
  def show
    legislator = Legislator.find(params[:id])
    term = legislator.terms.find_by(congress_id: params[:congress_id])
    
    render locals: { legislator: legislator, term: term }
  end
  
  def disclosures
    legislator = Legislator.find(params[:id])
    term = Term.find(params[:term])
    disclosures = legislator.disclosures.where(year: [(term.start_year)..(term.end_year)])
    
    render locals: { legislator: legislator, term: term, disclosures: disclosures }
  end

  def voting_record
    legislator = Legislator.find(params[:id])
    term = Term.find(params[:term])
  end
end
