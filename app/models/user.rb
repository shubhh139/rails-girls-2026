class User < ApplicationRecord
  has_secure_password

  has_one  :donor_profile, dependent: :destroy
  has_many :blood_requests, dependent: :destroy
  has_many :responses, foreign_key: :donor_id, dependent: :destroy

  normalizes :email_address, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true
end
