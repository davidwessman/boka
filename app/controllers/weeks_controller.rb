class WeeksController < ApplicationController
  def update
    week = Week.find(params[:id])
    WeekJob.perform_later(week)
    redirect_to(
      root_path(week: week.number),
      notice: "Week #{week.number} is being updated."
    )
  end
end
