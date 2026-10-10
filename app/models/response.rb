class Response < ApplicationRecord
  belongs_to :blood_request
  belongs_to :donor
end
