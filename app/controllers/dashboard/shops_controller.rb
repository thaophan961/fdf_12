class Dashboard::ShopsController < ApplicationController
  before_action :load_shop, only: [:show, :edit, :update]
  before_action :load_params_update, only: :show

  def new
    @shop = current_user.own_shops.build
  end

  def create
    @shop = current_user.own_shops.build shop_params
    if @shop.save
      message_CW = t "msg_cw_shop"
      send_chatwork_message message_CW
      flash[:success] = t "flash.success.dashboard.created_shop"
      redirect_to shops_path
    else
      flash[:danger] = t "flash.danger.dashboard.created_shop"
      render :new
    end
  end

  def show
    @shop = @shop.decorate
    @products = @shop.products.page(params[:page])
      .per Settings.common.products_per_page
    if @start_hour.present? and @end_hour.present?
      if compare_time_order @start_hour, @end_hour
        @products.update_all status: :active, start_hour: @start_hour,
          end_hour: @end_hour
        flash.now[:success] = t "dashboard.shops.show.update_success"
      else
        flash.now[:danger] = t "dashboard.shops.show.update_faild"
      end
    end
  end

  def index
    @shops = current_user.own_shops.page(params[:page])
      .per(Settings.common.per_page).decorate
  end

  def edit
  end

  def update
    if @shop.update_attributes shop_params
      flash[:success] = t "flash.success.dashboard.updated_shop"
      redirect_to dashboard_shop_path(@shop)
    else
      flash[:danger] = t "flash.danger.dashboard.updated_shop"
      render :edit
    end
  end

  private
  def shop_params
    params.require(:shop).permit :id, :name, :description,
      :cover_image, :avatar, :time_auto_reject
  end

  def load_params_update
    @start_hour = params[:start_hour]
    @end_hour = params[:end_hour]
  end

  def load_shop
    if Shop.exists? params[:id]
      @shop = Shop.find params[:id]
    else
      flash[:danger] = t "flash.danger.load_shop"
      redirect_to root_path
    end
  end
end
