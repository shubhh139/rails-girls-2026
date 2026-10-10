class DonorsController < ApplicationController
  def index
    @donors = DonorProfile.includes(:user).where(available: true).order(created_at: :desc)
    @donors = @donors.where(blood_group: params[:blood_group]) if params[:blood_group].present?
    @donors = @donors.where(city: params[:city]) if params[:city].present?
  end
end
