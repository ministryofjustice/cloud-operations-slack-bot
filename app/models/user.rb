class User < ApplicationRecord
  validates :slack_handle, presence: true, uniqueness: { case_sensitive: false, scope: :channel_handle }
  validates :channel_handle, presence: true, uniqueness: { case_sensitive: false, scope: :slack_handle }

  scope :for_channel, ->(channel_id) { where('channel_handle == ?', channel_id ) }
end