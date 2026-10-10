class BloodRequestsController < ApplicationController
  # Module D: Requests list. See specs/module-d-requests-list.md.
  def index
    @blood_requests = BloodRequest.order(created_at: :desc)
    @blood_requests = @blood_requests.where(blood_group: params[:blood_group]) if params[:blood_group].present?
  end

  # Module C: Blood requests. See specs/module-c-blood-requests.md.
  def show
  end

  # Module C
  def new
  end

  # Module C
  def create
  end
end
