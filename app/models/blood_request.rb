class BloodRequest < ApplicationRecord
  belongs_to :user
  has_many :responses, dependent: :destroy

  validates :patient_name, :hospital, :contact_phone, :needed_by, presence: true
  validates :blood_group, inclusion: { in: BLOOD_GROUPS }
  validates :city, inclusion: { in: CITIES }
  validates :units_needed, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
end
