class LocationsController < ApplicationController
  def index
    @locations = Location.all
  end

  def show
    @location = Location.find(params[:id])
    @slots = @location.slots.future.order(:start_at)
  end
end
