class Slot < ApplicationRecord
  belongs_to :location
  belongs_to :week
end
