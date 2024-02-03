class WeekJob < ApplicationJob
  queue_as :default

  def perform(week)
    district = "CITY"
    activity = "INNE"
    times = [%w[1800 1900], %w[1900 2000], %w[2000 2100]]
    urls =
      week.weekdays.flat_map do |weekday|
        times.map do |start_at, end_at|
          search_url(
            date: weekday,
            start_at: start_at,
            end_at: end_at,
            district: district,
            activity: activity
          )
        end
      end

    SearchScraper.run(start_urls: urls, headless: false) do |parsed|
      parsed[:locations].each do |location_data|
        Slot.find_or_create_by!(
          location: prepare_location(location_data),
          start_at: parsed[:start_at],
          end_at: parsed[:end_at],
          week: week
        )
      end
    end
    LocationJob.perform_later

    week.update!(scraped_at: Time.current)
  end

  def search_url(date:, start_at:, end_at:, district:, activity:)
    url = "https://booking.stockholm.se/SearchScheme/Search_Scheme_Result.aspx"
    url = URI.parse(url)
    query = (url.query ? CGI.parse(url.query) : {})
    query["Activity"] = activity
    query["District"] = district
    query["Start"] = start_at
    query["End"] = end_at
    query["Number"] = ""
    query["Date"] = date
    query["DateTom"] = date
    query["SchemeType"] = "0"

    url.query = URI.encode_www_form(query)
    url.to_s
  end

  def prepare_location(data)
    Location.find_or_create_by!(
      title: data[:title],
      facility_id: data[:facility_id],
      facility_object_id: data[:facility_object_id]
    )
  end
end

class Scraper
  def self.search_week(week_number:, district: "CITY", activity: "INNE")
    week_numbers = Array(week_number)
    mondays =
      week_numbers.map do |week_number|
        if week_number < Date.current.cweek
          Date.commercial(Date.current.year + 1, week_number, 1)
        else
          Date.commercial(Date.current.year, week_number, 1)
        end
      end

    times = [%w[1800 1900], %w[1900 2000], %w[2000 2100]]
    skip_locations = ["Karlbergs skola", "Essinge Skola", "Klastorpsskolan"]

    urls =
      mondays.flat_map do |monday|
        (0..4).flat_map { |i| date = monday + i.days }
      end

    SearchScraper.run(start_urls: urls, headless: false) do |parsed|
      parsed[:locations].each do |location_data|
        Slot.find_or_create_by!(
          location: prepare_location(location_data),
          start_at: parsed[:start_at],
          end_at: parsed[:end_at]
        )
      end
    end
  end
end
