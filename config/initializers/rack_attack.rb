# frozen_string_literal: true

# Rack::Attack: Handles rate limiting and security headers
# @attr_reader limit, period, ip

class Rack::Attack
    # Throttle forecasts to 10 requests per minute per IP
    throttle('forecasts/create/ip', limit: 10, period: 60.seconds) do |req|
      if req.path == '/forecasts' && req.post?
        req.ip
      end
    end
end