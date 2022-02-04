class User < ApplicationRecord
  validates :slack_handle, presence: true, uniqueness: { case_sensitive: false }
  validates :channel_handle, presence: true, uniqueness: { case_sensitive: false }

end