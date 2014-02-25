module Neighborly::Balanced::Bankaccount
  class RoutingNumbersController < ActionController::Base

    def show
      routing_number = RoutingNumber.where(number: params[:id]).first
      render json: { ok: routing_number.present?, bank_name: routing_number.try(:bank_name) }
    end

  end
end
