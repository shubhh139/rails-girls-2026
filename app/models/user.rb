class User < ApplicationRecord
  has_one :donor_profile, dependent: :destroy
end
