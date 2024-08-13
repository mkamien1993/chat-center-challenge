class UpdateShippingStatusJob < ApplicationJob
  queue_as :default

  def perform
    orders_to_update = Order.not_processing
    update_order_statuses(orders_to_update)
  end

  private

  def update_order_statuses(orders)
    orders.find_in_batches(batch_size: 100) do |batch|
      successful_order_ids, unsuccessful_order_ids = process_batch(batch)
      send_status_update_email(successful_order_ids) if unsuccessful_order_ids.empty?
    end
  end

  def process_batch(batch)
    successful_order_ids = []
    unsuccessful_order_ids = []

    batch.each do |order|
      update_order_status(order, successful_order_ids, unsuccessful_order_ids)
    end

    [successful_order_ids, unsuccessful_order_ids]
  end

  def update_order_status(order, successful_order_ids, unsuccessful_order_ids)
    shipment_status = shipment_status(order)
    new_local_status = map_fedex_status_to_local(shipment_status)

    if new_local_status && order.status != new_local_status
      order.update!(status: new_local_status)
      successful_order_ids << order.id
    end

  rescue StandardError => e
    Rails.logger.error("Failed to update status for order #{order.id}: #{e.message}")
    unsuccessful_order_ids << order.id
  end

  def shipment_status(order)
    cache_key = "fedex_shipment_status_#{order.fedex_id}"

    cached_status = Rails.cache.read(cache_key)
    return cached_status if cached_status

    begin
      status = Fedex::Shipment.find(order.fedex_id).status
      status
    rescue Fedex::ShipmentNotFound
      shipment = Fedex::Shipment.create
      order.update!(fedex_id: shipment.id)
      status = shipment.status
      status
    ensure
      Rails.cache.write(cache_key, status, expires_in: 24.hours)
    end
  end

  def map_fedex_status_to_local(fedex_status)
    case fedex_status
    when 'awaiting_pickup'
      :awaiting_pickup
    when 'in_transit'
      :in_transit
    when 'out_for_delivery'
      :out_for_delivery
    when 'delivered'
      :delivered
    else
      nil
    end
  end

  def send_status_update_email(order_ids)
    OrderMailer.status_update_email(order_ids).deliver_later
  end
end
