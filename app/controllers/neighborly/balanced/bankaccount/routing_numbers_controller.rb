module Neighborly::Balanced::Bankaccount
  class RoutingNumbersController < ApplicationController
    skip_before_filter :force_http

    def show
      routing_number = RoutingNumber.where(number: params[:id]).first
      render json: { ok: routing_number.present?, bank_name: routing_number.try(:bank_name) }
    end

  end
end
