class OrderSearchService
  def initialize(params)
    @params = params
  end

  def call
    orders = Order.includes(:product).all
    orders = filter_by_product_id(orders) if params[:product_id].present?
    orders = filter_by_customer_name(orders) if params[:customer_name].present?
    orders = filter_by_status(orders) if params[:status].present?
    orders = filter_by_created_at(orders) if params[:created_at].present?
    orders
  end

  private

  attr_reader :params

  def filter_by_product_id(orders)
    orders.where(product_id: params[:product_id])
  end

  def filter_by_customer_name(orders)
    orders.where("customer_name ILIKE ?", "%#{params[:customer_name]}%")
  end

  def filter_by_status(orders)
    orders.where(status: params[:status])
  end

  def filter_by_created_at(orders)
    orders.where("DATE(created_at) = ?", Date.parse(params[:created_at]))
  end
end
