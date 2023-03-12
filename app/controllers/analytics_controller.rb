class AnalyticsController < ApplicationController
  before_action :set_should_render_navbar
  def show
    @daily_profile_views = current_user.get_daily_profile_views
    @daily_link_clicks = current_user.get_daily_link_clicks

    @device_views = current_user.get_daily_views_by_device_type.count
    # 2 items
    # { "desktop" => 23, "mobile" => 13 }
    @daily_views_by_device_type = @device_views.map do |key, value|
      { name: "#{key} #{value}", data: value }
    end
  end

  private

  def set_should_render_navbar
    @should_render_navbar = true
  end
end
