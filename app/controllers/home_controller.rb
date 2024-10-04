class HomeController < ApplicationController
  
  def home
    respond_to do |format|
      format.html do
        render :home, locals: { congresses: congresses, congress: current_congress }
      end
    end
  end

  def congress
    # legislators = Legislator.joins(:terms).where(terms: {congress: current_congress})
    # @house = legislators.where(terms: {chamber: "House of Representatives"})
    # @senate = legislators.where(terms: {chamber: "Senate"})
    state_info = State.congress_info(congress: current_congress)
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
    @current_congress ||= (params[:congress] ? Congress.find(params[:congress]) : congresses.first)
  end

  def congresses
    @congresses ||= Congress.order(start_year: :desc)
  end
end
