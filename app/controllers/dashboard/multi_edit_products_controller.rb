class Dashboard::MultiEditProductsController < ApplicationController
  before_action :load_shop, only: :update
  before_action :load_categories, only: :update
  before_action :load_product, only: :update

  def update
    @products = Product.all
      @products.each do |product|
        product.update_attributes product_params
        respond_to do |format|
          format.json do
            render json: {status: @product.status}
          end
          format.html {redirect_to dashboard_shop_path @shop}
        end
      end
    flash[:notice] = "Updated products!"
    redirect_to  dashboard_shop_products_path
  end

  private
  def product_params
    params.require(:product).permit :start_hour, :end_hour
  end

  def load_categories
    @categories = Category.all
  end

  def load_product
    if Product.exists? params[:id]
      @product = @shop.products.find params[:id]
    else
      flash[:danger] = t "flash.danger.dashboard.product.not_found"
      redirect_to dashboard_shop_products_path
    end
  end

  def load_shop
    if Shop.exists? params[:shop_id]
      @shop = Shop.find params[:shop_id]
    else
      flash[:danger] = t "flash.danger.load_shop"
      redirect_to dashboard_shop_path
    end
  end
end
