class HomeController < ApplicationController
  
  def home
    @congresses = Term.distinct.pluck(:congress).sort.reverse

    @home = { congress: @congress }

    respond_to do |format|
      format.html
    end
  end

  def congress
    # legislators = Legislator.joins(:terms).where(terms: {congress: current_congress})
    # @house = legislators.where(terms: {chamber: "House of Representatives"})
    # @senate = legislators.where(terms: {chamber: "Senate"})
    state_info = State.congress_info(congress_number: current_congress)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          :congress_turbo_frame,
          partial: "congress",
          locals: { state_info: state_info }
        )
      end
    end
  end

  private

  def current_congress
    @current_congress ||= params[:congress] || congresses.last
  end

  def congresses
    @congresses ||= Term.distinct.pluck(:congress).sort.reverse
  end
end
