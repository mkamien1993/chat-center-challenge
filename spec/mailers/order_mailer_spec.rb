require 'rails_helper'

RSpec.describe OrderMailer do
  describe '#status_update_email' do
    let!(:orders) { create_list(:order, 3, status: :delivered) }
    let(:mail) { OrderMailer.status_update_email(orders.map(&:id)) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Order Status Update')
      expect(mail.to).to eq([ENV['OPERATIONS_MANAGER_EMAIL']])
      expect(mail.from).to eq(['order_updates@example.com'])
    end

    it 'renders the plain text and the HTML version' do
      orders.each do |order|
        expect(mail.text_part.body.encoded).to include("Order ID: #{order.id}")
        expect(mail.text_part.body.encoded).to include("Status: #{order.status}")

        expect(mail.html_part.body.encoded).to include("<li>Order ID: #{order.id}, Status: #{order.status}</li>")
      end
    end
  end
end