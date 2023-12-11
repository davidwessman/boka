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
        (0..4).flat_map do |i|
          date = monday + i.days
          times.map do |start_at, end_at|
            search_url(
              date: monday + i.days,
              start_at: start_at,
              end_at: end_at,
              district: district,
              activity: activity
            )
          end
        end
      end

    results = {}
    SearchScraper.run(start_urls: urls, headless: false) do |parsed|
      locations = parsed[:locations] - skip_locations
      next unless locations.any?

      date = "#{parsed[:date]} #{parsed[:weekday]}"

      results[date] ||= {}
      results[date][parsed[:start_at]] ||= []
      results[date][parsed[:start_at]] += locations
    end
    results
  end

  def self.search_url(date:, start_at:, end_at:, district:, activity:)
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
end
