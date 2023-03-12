class DashboardController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_user, only: [:show]
  before_action :set_should_render_navbar, except: [:show]

  def index; end

  def appearance; end


  def show
    redirect_to dashboard_path if @user.nil?
    puts "#{@user}"
    @links = @user.links.where.not(url: '', title: '')
    ahoy.track 'Viewed Dashboard', user: @user

  end

  private

  def set_should_render_navbar
    @should_render_navbar = true
  end

  def set_user
    # localhost:3000/1
    @user = User.friendly.find(params[:id])
  rescue StandardError
    @user = nil
  end
end
