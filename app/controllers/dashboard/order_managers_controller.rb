class Dashboard::OrderManagersController < ApplicationController
  before_action :load_shop, only: :index

  def index
    @order_products_done = OrderProduct.history_by_day_with_status(@shop.id,
      OrderProduct.statuses[:done]).group_by{|i| l(i.created_at, format: :short_date)}
    @order_products_reject = OrderProduct.history_by_day_with_status(@shop.id,
      OrderProduct.statuses[:rejected]).group_by{|i| l(i.created_at, format: :short_date)}
    if params[:start_date].present? && params[:end_date].present?
      @order_products_done = @order_products_done
        .select {|key| (params[:start_date]..params[:end_date]).include? key}
      @order_products_reject = @order_products_reject
        .select {|key| (params[:start_date]..params[:end_date]).include? key}
    else
      @order_products_done = @order_products_done
        .select {|key| key == Time.now.strftime(t "time.formats.short_date")}
      @order_products_reject = @order_products_reject
        .select {|key| key == Time.now.strftime(t "time.formats.short_date")}
    end
  end

  private
  def load_shop
    if Shop.exists? params[:shop_id]
      @shop = Shop.find params[:shop_id]
      unless @shop.is_owner? current_user
        flash[:danger] = t "flash.danger.load_shop"
        redirect_to dashboard_shops_path
      end
    else
      flash[:danger] = t "flash.danger.load_shop"
      redirect_to dashboard_shops_path
    end
  end
end
