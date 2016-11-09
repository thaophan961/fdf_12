class Dashboard::ProductsController < BaseDashboardController
  before_action :load_shop
  before_action :load_categories, only: [:edit, :new, :update]
  before_action :load_product, except: [:index, :new, :create]
  before_action :load_products, only: :index

  def new
    @product = @shop.products.new
  end

  def index
    @products.page(params[:page]).per Settings.common.products_per_page
  end

  def show
    @order_item = OrderProduct.find_by id: params[:order_product_id]
    if @order_item
      case
      when @order_item.done?
        @order_products = @product.order_products.doned
      when @order_item.rejected?
        @order_products = @product.order_products.rejected
      else
        @order_products = @product.order_products.accepted
      end
    else
      flash[:danger] = t "flash.danger.dashboard.product.not_found"
      redirect_to dashboard_shop_products_path
    end
  end

  def edit
  end

  def create
    @product = @shop.products.new product_params
    if @product.save
      flash[:success] = t "flash.success.dashboard.create_product"
      redirect_to dashboard_shop_path @shop
    else
      flash[:danger] = t "flash.danger.dashboard.create_product"
      load_categories
      render :new
    end
  end

  def update
    if @product.update_attributes product_params
      flash[:success] = t "flash.success.dashboard.edit_product"
      respond_to do |format|
        format.json do
          render json: {status: @product.status}
        end
        format.html {redirect_to dashboard_shop_path @shop}
      end
    else
      flash[:danger] = t "flash.danger.dashboard.edit_product"
      render :edit
    end
  end

  def destroy
    if @product.order_products.any?
      flash[:danger] = t "flash.danger.dashboard.order_product"
    elsif @product.destroy
      flash[:success] = t "flash.success.dashboard.delete_product"
    else
      flash[:danger] = t "flash.danger.dashboard.delete_product"
    end
    redirect_to dashboard_shop_path @shop
  end

  private
  def load_shop
    if Shop.exists? params[:shop_id]
      @shop = Shop.find params[:shop_id]
    else
      flash[:danger] = t "flash.danger.load_shop"
      redirect_to dashboard_shop_path
    end
  end

  def product_params
    params.require(:product).permit :id, :name, :description, :price,
      :category_id, :user_id, :image, :status, :tag_list, :start_hour, :end_hour
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

  def load_products
    @products = @shop.products
  end
end
