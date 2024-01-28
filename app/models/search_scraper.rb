class SearchScraper < Vessel::Cargo
  def parse
    # Parse url from `onclick` and find location title and ID
    locations =
      css(".gridrow").map do |row|
        td = row.at_css("td")
        query = td.attribute("onclick")&.split("ShowBookingSchedule.aspx?").last
        query = CGI.parse(query) || {}
        {
          id: query["Facility"]&.first,
          title: query["FacilityName"]&.first,
          object_id: query["Object"]&.first
        }
      end
    query = URI.parse(current_url).query
    params = CGI.parse(query) || {}

    date = Date.parse(params["Date"]&.first)

    yield(
      {
        date: date.to_s,
        weekday: date.strftime("%A"),
        start_at: params["Start"]&.first,
        end_at: params["End"]&.first,
        locations: locations
      }
    )
  end
end
