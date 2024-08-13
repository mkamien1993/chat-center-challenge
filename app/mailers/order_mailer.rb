class OrderMailer < ApplicationMailer
  default from: 'order_updates@example.com'

  def status_update_email(order_ids)
    @orders = Order.where(id: order_ids)

    mail(to: ENV['OPERATIONS_MANAGER_EMAIL'], subject: 'Order Status Update')
  end
end
