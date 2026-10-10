class BloodRequestsController < ApplicationController
  # Module D: Requests list. See specs/module-d-requests-list.md.
  def index
  end

  # Module C: Blood requests. See specs/module-c-blood-requests.md.
  def show
    @blood_request = BloodRequest.find(params[:id])
  end

  # Module C
  def new
    @blood_request = BloodRequest.new
  end

  # Module C
  def create
    @blood_request = Current.user.blood_requests.new(blood_request_params)

    if @blood_request.save
      redirect_to @blood_request, notice: "Request posted."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def blood_request_params
    params.expect(blood_request: [ :patient_name, :blood_group, :units_needed, :hospital,
                                   :city, :needed_by, :contact_phone, :note ])
  end
end
