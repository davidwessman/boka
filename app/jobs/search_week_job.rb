class SearchWeekJob < ApplicationJob
  limits_concurrency(to: 1, key: :create_location_job)
  queue_as(:default)

  def perform(week)
    Scraper.search_week(week_number: week)
  end
end
