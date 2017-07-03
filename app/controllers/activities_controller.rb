class ActivitiesController < ApplicationController
  def activities
    @activities = PublicActivity::Activity.all
  end
end
