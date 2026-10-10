class PagesController < ApplicationController
  allow_unauthenticated_access

  def home
  end

  # A page showing every component class from UI_DESIGN.md, for reference while building.
  def styleguide
  end
end
