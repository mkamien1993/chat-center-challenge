require 'rails_helper'

RSpec.describe "Orders" do
  let!(:admin) { create(:user, :admin, email: "mat@gmail.com") }
  let!(:regular_user) { create(:user, email: "ber@gmail.com") }
  let(:order) { create(:order) }

  describe "GET /orders" do
    context "when user is an admin" do
      it "allows access to the orders page" do
        sign_in admin
        get orders_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not an admin" do
      it "redirects to the root path with an alert" do
        sign_in regular_user
        get orders_path
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("You are not authorized to access Orders dashboard. Only admins are allowed.")
      end
    end
  end

  describe "GET /orders/:id" do
    context "when the user is an admin" do
      it "returns a successful response" do
        sign_in admin
        get order_path(order)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(order.customer_name)
      end
    end

    context "when the user is not an admin" do
      it "redirects to the root path with an alert" do
        sign_in regular_user
        get order_path(order)
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('You are not authorized to access Orders dashboard. Only admins are allowed.')
      end
    end
  end

  describe "GET /orders/new" do
    context "when the user is an admin" do
      it "returns a successful response" do
        sign_in admin
        get new_order_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('New Order')
      end
    end

    context "when the user is not an admin" do
      it "redirects to the root path with an alert" do
        sign_in regular_user
        get new_order_path
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('You are not authorized to access Orders dashboard. Only admins are allowed.')
      end
    end
  end

  describe "POST /orders" do
    context "when the user is an admin" do
      let!(:product) { Product.create!(name: "Prod A", stock: 10, price: 10) }

      before { sign_in admin}

      context "with valid parameters" do
        let(:valid_attributes) { { product_id: product.id, customer_name: "Jorge Perez" } }

        it "creates a new order" do
          expect {
            post orders_path, params: { order: valid_attributes }
          }.to change(Order, :count).by(1)
        end

        it "redirects to the created order with a notice" do
          post orders_path, params: { order: valid_attributes }
          expect(response).to redirect_to(Order.last)
          follow_redirect!
          expect(response.body).to include('Order was successfully created.')
        end
      end

      context "with invalid parameters" do
        let(:invalid_attributes) { { product_id: product.id } }

        it "does not create a new order" do
          expect {
            post orders_path, params: { order: invalid_attributes }
          }.not_to change(Order, :count)
        end

        it "re-renders the new template" do
          post orders_path, params: { order: invalid_attributes }
          expect(response.body).to include('1 error prohibited this order from being saved')
        end
      end
    end

    context "when the user is not an admin" do
      it "redirects to the root path with an alert" do
        sign_in regular_user
        post orders_path, params: { order: attributes_for(:order) }
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('You are not authorized to access Orders dashboard. Only admins are allowed.')
      end
    end
  end

  describe "SEARCH /orders/search" do
    context "when user is an admin" do
      it "allows access to the orders page" do
        sign_in admin
        get search_orders_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not an admin" do
      it "redirects to the root path with an alert" do
        sign_in regular_user
        get search_orders_path
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("You are not authorized to access Orders dashboard. Only admins are allowed.")
      end
    end
  end
end
