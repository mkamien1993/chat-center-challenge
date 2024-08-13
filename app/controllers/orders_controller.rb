class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.includes(:product).all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @order = Order.find(params[:id])
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def search
    @orders = OrderSearchService.new(params).call
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:product_id, :customer_name, :status)
  end

  def authorize_admin
    unless current_user&.admin?
      flash[:alert] = "You are not authorized to access Orders dashboard. Only admins are allowed."
      redirect_to root_path
    end
  end
end
