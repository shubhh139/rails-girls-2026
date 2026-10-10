class DonorProfilesController < ApplicationController
  before_action :set_donor_profile, only: [:edit, :update]

  def new
    if Current.user && Current.user.donor_profile
      redirect_to edit_donor_profile_path
    else
      @donor_profile = DonorProfile.new
    end
  end

  def create
    if Current.user && Current.user.donor_profile
      redirect_to edit_donor_profile_path, alert: 'You already have a donor profile.'
      return
    end

    @donor_profile = Current.user.build_donor_profile(donor_profile_params)

    if @donor_profile.save
      redirect_to donors_path, notice: 'Your donor profile is saved.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @donor_profile.update(donor_profile_params)
      redirect_to edit_donor_profile_path, notice: 'Your donor profile is updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_donor_profile
    @donor_profile = Current.user && Current.user.donor_profile
    redirect_to new_donor_profile_path, alert: 'Create your donor profile first.' unless @donor_profile
  end

  def donor_profile_params
    params.expect(donor_profile: [:blood_group, :city, :phone, :available])
  end
end
