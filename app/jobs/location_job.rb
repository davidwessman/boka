class LocationJob < ApplicationJob
  limits_concurrency(to: 1, key: :create_location_job)
  queue_as(:default)

  def perform(*)
    locations =
      Location
        .where(scraped_at: nil)
        .or(Location.where(scraped_at: ..1.day.ago))
        .index_by(&:full_facility_id)

    LocationScraper.run(
      start_urls: locations.values.map(&:url),
      headless: false
    ) do |parsed|
      location =
        locations["#{parsed[:facility_id]}-#{parsed[:facility_object_id]}"]

      location.update!(
        title: parsed[:title],
        subtitle: parsed[:subtitle],
        address: parsed[:address],
        postal_code: parsed[:postal_code],
        city: parsed[:city],
        district: parsed[:district],
        scraped_at: Time.current
      )
    end
  end
end
