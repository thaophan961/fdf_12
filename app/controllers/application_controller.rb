class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :create_cart
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :load_events

  include ApplicationHelper

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit :name, :email, :chatwork_id, :avatar, :description,
        :password, :password_confirmation
    end
    devise_parameter_sanitizer.permit(:account_update) do |user_params|
      user_params.permit :name, :email, :chatwork_id, :avatar, :description,
        :password, :password_confirmation, :current_password
    end
  end

  private
  def create_cart
    @cart = Cart.build_from_hash session[:cart]
    @cart_group = @cart.items.group_by(&:shop_id).map  do |q|
      {shop_id: q.first, items: q.second.each.map { |qn| qn }}
    end
  end

  def load_events
    if user_signed_in?
      @events = current_user.events.by_date
      @count_unread_notification = @events.unread.size
    end
  end

  def load_shop
    @shop = Shop.find_by id: params[:shop_id]
    unless @shop
      flash[:danger] = t "flash.danger.load_shop"
      redirect_to dashboard_shops_path
    end
  end
end
