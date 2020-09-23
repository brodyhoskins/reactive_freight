# frozen_string_literal: true

module ReactiveShipping
  class TOTL < CarrierLogistics
    REACTIVE_FREIGHT_CARRIER = true

    cattr_reader :name
    @@name = 'Total Transportation'

    def requirements
      %i[username password account]
    end

    # Documents

    # Rates
    def build_calculated_accessorials(*); end

    # Tracking

    # protected

    # Documents

    # Rates

    def parse_rate_response(origin, destination, packages, response)
      success = true
      message = ''

      if !response
        success = false
        message = 'API Error: Unknown response'
      else
        response = response.parsed_response
        if response['error']
          success = false
          message = response['error']
        else
          cost = response.dig('ratequote', 'quotetotal').delete(',').delete('.').to_i
          days = response.dig('ratequote', 'busdays').to_i
          delivery_range = [days, days]
          if cost
            # Carrier-specific pricing structure
            oversized_pallets_price = 0
            packages.each do |package|
              short_side, long_side = nil
              if !package.inches[0].blank? && !package.inches[1].blank? && !package.inches[2].blank?
                long_side = package.inches[0] > package.inches[1] ? package.inches[0] : package.inches[1]
                short_side = package.inches[0] < package.inches[1] ? package.inches[0] : package.inches[1]
              end

              next unless short_side &&
                          long_side &&
                          package.inches[2] &&
                          (
                            short_side > 40 ||
                            long_side > 48 ||
                            package.inches[2] > 84
                          )

              oversized_pallets_price += 1500
            end
            cost += oversized_pallets_price

            rate_estimates = [
              RateEstimate.new(
                origin,
                destination,
                self.class.name.split('::')[1],
                :standard,
                delivery_range: delivery_range,
                estimate_reference: nil,
                total_price: cost,
                currency: 'USD'
              )
            ]
          else
            success = false
            message = 'API Error: Cost is emtpy'
          end
        end
      end

      RateResponse.new(
        success,
        message,
        response.to_hash,
        rates: rate_estimates,
        response: response,
        request: last_request
      )
    end
  end
end
