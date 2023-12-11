class Scraper
  URL = "https://booking.stockholm.se/SearchScheme/AdvancedSearch.aspx"

  def initialize
    @browser = Ferrum::Browser.new(headless: true)
  end

  def cleanup
    @browser.quit
  end

  def self.search_week(dates)
    scraper = new
    return dates.map { |date| scraper.search_week(date:) }
  ensure
    scraper.cleanup
  end

  def search_week(date:)
    monday = Date.parse(date).monday

    times = [%w[1800 1900], %w[1900 2000], %w[2000 2100]]

    (0..4)
      .filter_map do |i|
        date = monday + i.days
        result = {}
        times.each do |start_at, end_at|
          search_results =
            search(date: date, start_at: start_at, end_at: end_at)
          result[
            "#{start_at}-#{end_at}"
          ] = search_results if search_results.any?
        end

        [date, result] if result.any?
      end
      .to_h
  end

  def self.search_week2(week_number:)
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
              end_at: end_at
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

  def self.search_url(date:, start_at:, end_at:)
    # https://booking.stockholm.se/SearchScheme/Search_Scheme_Result.aspx?Activity=INNE&District=CITY&Start=1900&End=2000&Number=&Date=2024-01-08&DateTom=2024-01-15&SchemeType=0&ReqHits=&DayOfWeeks=1@2@3@4@5@6@7&FirstAvailable=False
    url = "https://booking.stockholm.se/SearchScheme/Search_Scheme_Result.aspx"
    url = URI.parse(url)
    query = (url.query ? CGI.parse(url.query) : {})
    query["Activity"] = "INNE"
    query["District"] = "Nordost"
    query["Start"] = start_at
    query["End"] = end_at
    query["Number"] = ""
    query["Date"] = date
    query["DateTom"] = date
    query["SchemeType"] = "0"

    url.query = URI.encode_www_form(query)
    url.to_s
  end

  def search(date:, start_at:, end_at:)
    @browser.goto(search_url(date:, start_at:, end_at:))
    @browser.css(".gridrow").map { |row| row.at_css("td").inner_text }
  end
end
