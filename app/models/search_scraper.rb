class SearchScraper < Vessel::Cargo
  def parse
    locations = css(".gridrow").map { |row| row.at_css("td").inner_text }
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
