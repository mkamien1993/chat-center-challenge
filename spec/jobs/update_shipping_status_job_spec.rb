require "rails_helper"

RSpec.describe UpdateShippingStatusJob do
  include ActiveJob::TestHelper

  let!(:order1) { create(:order, :with_fedex_id, :awaiting_pickup) }
  let!(:order2) { create(:order, :with_fedex_id, :awaiting_pickup) }
  let!(:order3) { create(:order) } # Should not be updated
  let(:shipment) { double("Fedex::Shipment", status: "out_for_delivery") }

  before do
    allow(Fedex::Shipment).to receive(:find).and_return(shipment)
    other_shipment = double("Fedex::Shipment", status: "awaiting_pickup", id: 123)
    allow(Fedex::Shipment).to receive(:create).and_return(other_shipment)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe "#perform" do
    context "without errors" do
      it "updates the status of orders without processing status" do
        UpdateShippingStatusJob.perform_now

        expect(order1.reload.status).to eq("out_for_delivery")
        expect(order2.reload.status).to eq("out_for_delivery")
      end

      it "caches the shipment status" do
        expect(Rails.cache).to receive(:write).with("fedex_shipment_status_#{order1.fedex_id}", "out_for_delivery", expires_in: 24.hours)
        expect(Rails.cache).to receive(:write).with("fedex_shipment_status_#{order2.fedex_id}", "out_for_delivery", expires_in: 24.hours)

        UpdateShippingStatusJob.perform_now
      end

      it "reads the status from cache if available" do
        Rails.cache.write("fedex_shipment_status_#{order1.fedex_id}", "out_for_delivery", expires_in: 24.hours)
        Rails.cache.write("fedex_shipment_status_#{order2.fedex_id}", "in_transit", expires_in: 24.hours)

        UpdateShippingStatusJob.perform_now

        expect(order1.reload.status).to eq("out_for_delivery")
        expect(order2.reload.status).to eq("in_transit")
        expect(Fedex::Shipment).not_to have_received(:find)
      end

      it "does not update orders that are in processing state" do
        UpdateShippingStatusJob.perform_now

        expect(order3.reload.status).to eq("processing")
      end

      it "sends an email to the operations manager after processing a successful batch of orders" do
        expect(ActionMailer::Base.deliveries.count).to eq(0)

        perform_enqueued_jobs do
          UpdateShippingStatusJob.perform_now
        end

        expect(ActionMailer::Base.deliveries.count).to eq(1)

        mail = ActionMailer::Base.deliveries.last
        expect(mail).not_to be_nil
        expect(mail.subject).to eq("Order Status Update")
        expect(mail.to).to include(ENV["OPERATIONS_MANAGER_EMAIL"])
      end
    end

    context "when a shipment is not found" do
      before { allow(Fedex::Shipment).to receive(:find).and_raise(Fedex::ShipmentNotFound) }

      it "creates a new shipment and updates the order with the new id" do
        UpdateShippingStatusJob.perform_now

        expect(order1.reload.fedex_id).to eq(123)
        expect(order1.status).to eq("awaiting_pickup")
      end

      it "caches the new shipment status" do
        expect(Rails.cache).to receive(:write).with("fedex_shipment_status_#{order1.fedex_id}", "awaiting_pickup", expires_in: 24.hours)
        expect(Rails.cache).to receive(:write).with("fedex_shipment_status_#{order2.fedex_id}", "awaiting_pickup", expires_in: 24.hours)
        described_class.new.perform
      end
    end

    context "when an error is raised" do
      it "logs an error for each order that failed to be updated and does not send any email" do
        allow(Fedex::Shipment).to receive(:find).and_raise(StandardError.new("Unexpected error"))
        expect(Rails.logger).to receive(:error).with(/Failed to update status for order/).twice

        perform_enqueued_jobs do
          UpdateShippingStatusJob.perform_now
        end

        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
    end
  end
end
