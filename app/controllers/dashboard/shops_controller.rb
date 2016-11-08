class Dashboard::ShopsController < BaseDashboardController
  before_action :load_shop, only: [:show, :edit, :update, :update_multiple]

  def new
    @shop = current_user.own_shops.build
  end

  def create
    @shop = current_user.own_shops.build shop_params
    if @shop.save
      flash[:success] = t "flash.success.dashboard.created_shop"
      redirect_to shops_path
    else
      flash[:danger] = t "flash.danger.dashboard.created_shop"
      render :new
    end
  end

  def update_multiple
    time_start = params[:start_hour]
    time_end = params[:end_hour]
    time_start_converted = Time.now.
      change({ hour: time_start["{:minute_step=>5}(4i)"].to_i,
      min: time_start["{:minute_step=>5}(5i)"].to_i, sec: 0 })
    time_end_converted = Time.now.
      change({ hour: time_end["{:minute_step=>5}(4i)"].to_i,
      min: time_end["{:minute_step=>5}(5i)"].to_i, sec: 0 })

    sql = "UPDATE `products` SET `start_hour` =' #{time_start_converted.strftime("%I:%M:00")}', `end_hour` = '#{time_end_converted.strftime("%I:%M:00")}' WHERE "
    records_array = ActiveRecord::Base.connection.execute(sql)
    flash[:notice] = "Updated products!"
    redirect_to  dashboard_shop_path @shop
  end

  def show
    @shop = @shop.decorate
    @products = @shop.products.page(params[:page])
      .per Settings.common.products_per_page
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
      :cover_image, :avatar
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
