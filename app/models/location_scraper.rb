class LocationScraper < Vessel::Cargo
  def parse
    parameters = CGI.parse(current_url.query)

    yield(
      {
        facility_id: parameters["FacilityId"]&.first,
        facility_object_id: parameters["ObjectId"]&.first,
        title: at_css("#lblFacilityTxt").text,
        subtitle: at_css("#lblObjectTxt").text,
        address: at_css("#lblVisitAddTxt").text,
        postal_code: at_css("#lblPostCodeTxt").text,
        city: at_css("#lblCityTxt").text,
        district: at_css("#lblDistrictTxt").text,
        size: at_css("#lblSizeTxt").text,
        code_lock: at_css("#lblLockTxt").text,
        info: at_css("#lblBookInfoText").text
      }
    )
  end
end
