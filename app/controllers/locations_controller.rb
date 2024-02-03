class LocationsController < ApplicationController
  def index
    @week = (params[:week].presence || Time.current.to_date.cweek).to_i
    @results =
      Scraper.search_week(week_number: @week).sort_by { |date, _times| date }
  end
end
