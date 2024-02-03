class PresentationsController < ApplicationController
  def index
    week_number = (params[:week].presence || Time.current.to_date.cweek).to_i

    @week = Week.find_or_create_by!(number: week_number)

    if @week.scraped_at.nil? || @week.scraped_at < 1.day.ago
      WeekJob.perform_later(@week)
    end

    @slots_by_start_at =
      @week.slots.includes(:location).order(:start_at).group_by(&:start_at)
  end
end
