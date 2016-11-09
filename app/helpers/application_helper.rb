module ApplicationHelper
  def full_title page_title
    base_title = I18n.t "common.base_title"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def admin_full_title page_title
    base_title = I18n.t "common.admin_title"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def increase_one index
    index + 1
  end

  def paginate objects, options = {}
    options.reverse_merge! theme: "twitter-bootstrap-3"
    super objects, options
  end

  def count_notification_read
    if user_signed_in?
      number_noti =  @count_unread_notification
      if number_noti == Settings.notification.number_unread_not_display
        number_noti = ""
      else
        number_noti
      end
    end
  end

  def total_price price, quantity
    price * quantity
  end

  def format_price price
    price.to_i.to_s + t("cart.vnd")
  end

  def compare_time time_start, time_end
    time_end > time_start
  end
end
