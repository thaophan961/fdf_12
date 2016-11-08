class Product < ApplicationRecord
  acts_as_paranoid
  acts_as_taggable

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  def slug_candidates
    [:name, [:name, :id]]
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed? || super
  end

  belongs_to :category
  belongs_to :shop
  belongs_to :user

  has_many :order_products
  has_many :reviews, as: :reviewable
  has_many :comments, as: :commentable
  has_many :events, as: :eventable
  has_many :orders, through: :order_products

  enum status: {active: 0, inactive: 1}
  mount_uploader :image, ProductImageUploader
  validates :name, presence: true, length: {maximum: 50}
  validates :description, presence: true
  validate :image_size
  validate :start_hour_before_end_hour

  delegate :name, to: :shop, prefix: :shop, allow_nil: true
  delegate :avatar, to: :shop, prefix: :shop

  scope :by_date_newest, ->{order created_at: :desc}
  scope :by_active, ->{where status: :active}
  scope :top_products, -> do
    by_active.by_date_newest.limit Settings.index.max_products
  scope :by_shop, -> id {where shop_id: id if id.present?}
  end

  def self.update_multi  shopid, starttime, endtime
    Product.by_shop(shopid).each do |product|
      product.start_hour = starttime
      product.end_hour = endtime
    end
  end

  private
  def image_size
    max_size = Settings.pictures.max_size
    if image.size > max_size.megabytes
      errors.add :image, I18n.t("pictures.error_message", max_size: max_size)
    end
  end

  def start_hour_before_end_hour
    unless self
      if start_hour > end_hour
        errors.add :start_hour, I18n.t("error_message_time")
      end
    end
  end

  def price_modification
    start_hour
  end

  def price_modification=(new_start_hour)
    self.start_hour = new_start_hour
  end
end
