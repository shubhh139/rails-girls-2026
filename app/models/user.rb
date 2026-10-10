class User < ApplicationRecord
  has_secure_password

  normalizes :email_address, with: -> email_address { email_address.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true

  has_one :donor_profile, dependent: :destroy
end
