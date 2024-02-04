class Location < ApplicationRecord
  normalizes(:postal_code, with: ->(code) { code.gsub(/\s+/, "") })
  normalizes(:city, with: ->(city) { city.downcase.titleize })

  has_many(:slots, dependent: :destroy)

  def full_facility_id
    "#{facility_id}-#{facility_object_id}"
  end

  def full_address
    "#{address}, #{postal_code} #{city}"
  end

  def url
    "https://booking.stockholm.se/SearchScheme/Object_info.aspx?FacilityId=#{facility_id}&ObjectId=#{facility_object_id}&PartOfObject=+"
  end
end
