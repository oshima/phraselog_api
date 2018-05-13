class Like < ApplicationRecord
  belongs_to :user
  belongs_to :phrase

  validates :user, :phrase, presence: true
end
