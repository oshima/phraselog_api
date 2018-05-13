class Phrase < ApplicationRecord
  belongs_to :user
  has_many :notes, dependent: :delete_all
  has_many :likes, dependent: :delete_all

  validates :id_string, :title, :interval, :user, presence: true
  validates :title, length: { maximum: 64 }
  validates :interval, numericality: { greater_than_or_equal_to: 0.1, less_than_or_equal_to: 1 }

  def likes_count
    likes.size
  end
end
