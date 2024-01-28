class LocationsController < ApplicationController
  def index
    @week = params[:week].to_i || Time.current.to_date.cweek
    @results =
      Scraper.search_week(week_number: @week).sort_by { |date, _times| date }
  end
end
