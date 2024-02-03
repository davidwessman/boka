class SearchScraper < Vessel::Cargo
  def parse
    # Parse url from `onclick` and find location title and ID
    locations =
      css(".gridrow").map do |row|
        td = row.at_css("td")
        query = td.attribute("onclick")&.split("ShowBookingSchedule.aspx?").last
        query = CGI.parse(query) || {}
        {
          title: query["FacilityName"]&.first,
          facility_id: query["Facility"]&.first,
          facility_object_id: query["Object"]&.first
        }
      end

    query = URI.parse(current_url).query
    params = CGI.parse(query) || {}

    date = Date.parse(params["Date"]&.first)
    start_at = Time.zone.parse("#{date} #{time(params["Start"]&.first)}")
    end_at = Time.zone.parse("#{date} #{time(params["End"]&.first)}")

    yield({ start_at: start_at, end_at: end_at, locations: locations })
  end

  private

  def time(string)
    "#{string[0..1]}:#{string[2..3]}"
  end
end
