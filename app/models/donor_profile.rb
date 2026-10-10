class DonorProfile < ApplicationRecord
  belongs_to :user

  validates :blood_group, presence: true
  validates :blood_group, inclusion: { in: BLOOD_GROUPS }

  validates :city, presence: true
  validates :city, inclusion: { in: CITIES }

  validates :phone, presence: true
  validates :user_id, uniqueness: true
end
