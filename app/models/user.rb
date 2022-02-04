class User < ApplicationRecord
  validates :slack_handle, presence: true, uniqueness: { case_sensitive: false, scope: :channel_handle }
  validates :channel_handle, presence: true, uniqueness: { case_sensitive: false, scope: :slack_handle }

end