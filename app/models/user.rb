class User < ApplicationRecord
  validates :id_string, :display_name, :photo_url, presence: true
  validates :photo_url, format: /\A#{URI::regexp(%w(http https))}\z/
end
