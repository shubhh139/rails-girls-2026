class DonorProfile < ApplicationRecord
  BLOOD_GROUPS = ::BLOOD_GROUPS
  CITIES = ::CITIES

  belongs_to :user

  validates :blood_group, presence: true, inclusion: { in: BLOOD_GROUPS }
  validates :city, presence: true, inclusion: { in: CITIES }
  validates :phone, presence: true
  validates :user_id, uniqueness: true
end
