class Note < ApplicationRecord
  belongs_to :phrase

  validates :x, :y, :length, :phrase, presence: true
  validates :x, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :y, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 48 }
  validates :length, numericality: { only_integer: true, greater_than: 0 }
end
