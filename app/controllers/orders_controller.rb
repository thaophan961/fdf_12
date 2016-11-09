class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_shop, except: [:edit, :index]
  before_action :load_order, only: [:destroy, :show]
  before_action :load_order_update, only: :update

  def index
    if params[:start_date].present? && params[:end_date].present?
      @orders = current_user.orders.between_date params[:start_date],
        params[:end_date]
    else
      @orders = current_user.orders.on_today.by_date_newest.page(params[:page])
        .per Settings.common.per_page
    end
    @order_days = @orders.group_by{|t| t.created_at.beginning_of_day}
  end

  def new
    @orders = @shop.orders.accepted
    @order = @shop.orders.new
    @cart_shop = load_cart_shop
  end

  def show
  end

  def update
    @cart_shop = load_cart_shop
    if @cart_shop.present?
      if @order.update_attributes order_params @cart_shop
        delete_cart_item_shop session["cart"], @shop
        flash[:success] = t "oder.success"
        redirect_to order_path @order, shop_id: @shop.id
      else
        flash[:danger] = t "oder.not_oder"
        redirect_to new_order_path
      end
    else
      flash[:danger] = t "oder.not_product_in_cart"
      redirect_to carts_path
    end
  end


  def create
    @cart_shop = load_cart_shop
    if @cart_shop.present?
      @order = Order.new params_create_order @cart_shop
      if @order.save
        delete_cart_item_shop session["cart"], @shop
        flash[:success] = t "oder.success"
        redirect_to order_path @order, shop_id: @shop.id
      else
        flash[:danger] = t "oder.not_oder"
        redirect_to new_order_path
      end
    else
      flash[:danger] = t "oder.not_product_in_cart"
      redirect_to carts_path
    end
  end

  def destroy
    if @order.destroy
      flash[:success] = t "oder.deleted"
    else
      flash[:danger] = t "oder.not_delete"
    end
    redirect_to orders_path
  end

  private

  def order_params cart_shop
    {cart: cart_shop, shop: @shop, user: current_user}
  end

  def params_create_order cart_shop
    {user: current_user, total_pay: cart_shop.total_price,
      cart: cart_shop, shop: @shop}
  end

  def load_shop
    @shop = Shop.find_by id: params[:shop_id]
    unless @shop
      flash[:danger] = t "flash.danger.load_shop"
      redirect_to products_path
    end
  end

  def load_order
    @order = Order.find_by id: params[:id]
    unless @order
      flash[:danger] = t "load_order"
      redirect_to products_path
    end
  end

  def load_order_update
    @order = Order.open.find_by id: params[:id]
    unless @order
      flash[:danger] = t "flash.danger.load_order"
      redirect_to new_order_path(shop_id: @shop.id)
    end
  end

  def load_cart_shop
    cart_shop = @cart_group.detect {|shop| shop[:shop_id] == @shop.id}
    Cart.new cart_shop[:items] if cart_shop.present?
  end

  def delete_cart_item_shop cart, shop
    items = cart["items"].select{|item| item["shop_id"] == shop.id}
    if items.present?
      create_cart
      cart["items"] = cart["items"] - items
    end
  end
end
