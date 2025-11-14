class WeatherController < ApplicationController
  def show
    query = params[:q].to_s.strip

    if query.blank?
      @result = nil
      @error = nil
      render :show and return
    end

    result = WeatherFetcher.new(query).call

    if request.format.json?
      if result[:error]
        render json: { error: result[:error] }, status: :bad_request
      else
        render json: result, status: :ok
      end
    else
      if result[:error]
        @error = result[:error]
        @result = nil
      else
        @result = result
      end
      render :show
    end
  end
end

