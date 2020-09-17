module ReactiveShipping
  class TOTL < CarrierLogistics
    REACTIVE_FREIGHT_CARRIER = true

    cattr_reader :name
    @@name = 'Total Transportation'

    @platform = ReactiveShipping::CarrierLogistics

    def available_services(origin_country_code, destination_country_code, _options = {})
      country = ActiveUtils::Country.find('USA')
      if ActiveUtils::Country.find(origin_country_code) == country && ActiveUtils::Country.find(destination_country_code) == country
        return :standard
      end

      nil
    end

    def maximum_weight
      Measured::Weight.new(10_000, :pounds)
    end

    def requirements
      %i[username password account]
    end

    # Documents

    # Rates
    def build_calculated_accessorials(packages); end

    # Tracking

    # protected

    def conf
      conf_path = File.expand_path('..', __dir__)
      conf_path = File.join(conf_path, 'configuration', 'carriers', "#{self.class.to_s.split('::')[1].downcase}.yml")
      super.deep_merge(YAML.safe_load(File.read(conf_path), permitted_classes: [Symbol]))
    end

    # Documents

    # Rates

    def parse_rate_response(origin, destination, _packages, response, _options = {})
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
            _packages.each do |package|
              short_side, long_side = nil
              if !package.inches[0].blank? && !package.inches[1].blank? && !package.inches[2].blank?
                long_side = package.inches[0] > package.inches[1] ? package.inches[0] : package.inches[1]
                short_side = package.inches[0] < package.inches[1] ? package.inches[0] : package.inches[1]
              end

              if short_side && long_side && package.inches[2] && ((short_side > 40) || (long_side > 48) || (package.inches[2] > 84))
                oversized_pallets_price += 1500
              end
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
        request: nil
      )
    end
  end
end
