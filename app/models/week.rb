class Week < ApplicationRecord
  has_many(:slots, dependent: :destroy)

  def monday
    if number < Date.current.cweek
      Date.commercial(Date.current.year + 1, number, 1)
    else
      Date.commercial(Date.current.year, number, 1)
    end
  end

  def weekdays
    (0..4).map { |i| monday + i.days }
  end
end
