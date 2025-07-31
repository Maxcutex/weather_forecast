# frozen_string_literal: true

# ForecastsController: Handles weather forecast requests and display
class ForecastsController < ApplicationController
  def index; end

  def search
    forecast_outcome = ForecastService.run(address: forecast_params[:address])
    if forecast_outcome.valid?
      @forecast = forecast_outcome.result
    else
      redirect_to forecasts_path, alert: forecast_outcome.errors.full_messages.join(', ')
    end
  end

  private

  def forecast_params
    params.permit(:address)
  end
end
