# frozen_string_literal: true

require "rails_helper"

RSpec.describe ForecastsController, type: :controller do
  describe "GET #index" do
    it "renders the index template successfully" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
    end
  end

  describe "GET #search" do
    let(:address) { "123 Main St, Toronto" }

    context "when ForecastService returns a valid outcome" do
      let(:forecast_double) { instance_double("Dtos::Forecast") }
      let(:outcome_double)  { instance_double("Outcome", valid?: true, result: forecast_double) }

      before do
        allow(ForecastService).to receive(:run)
          .with(address: address)
          .and_return(outcome_double)
      end

      it "renders the search template (no redirect)" do
        get :search, params: { address: address }

        expect(ForecastService).to have_received(:run).with(address: address)
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:search)

        expect(assigns(:forecast)).to eq(forecast_double)
      end
    end

    context "when ForecastService returns an invalid outcome" do
      let(:errors_double)  { instance_double("Errors", full_messages: [ "Address can't be blank", "Weather Service is not available at this time. Please try again later." ]) }
      let(:outcome_double) { instance_double("Outcome", valid?: false, errors: errors_double) }

      before do
        allow(ForecastService).to receive(:run)
          .with(address: address)
          .and_return(outcome_double)
      end

      it "redirects to forecasts_path with an alert" do
        get :search, params: { address: address }

        expect(response).to redirect_to(forecasts_path)
        expect(flash[:alert]).to eq("Address can't be blank, Weather Service is not available at this time. Please try again later.")
      end
    end
  end
end
