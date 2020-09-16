module ReactiveShipping
  class DPHE < ReactiveShipping::Carrier
    REACTIVE_FREIGHT_CARRIER = true

    cattr_reader :name
    @@name = 'Dependable Highway Express'

    def available_services(origin_country_code, destination_country_code, _options = {})
      country = ActiveUtils::Country.find('USA')
      if ActiveUtils::Country.find(origin_country_code) == country && ActiveUtils::Country.find(destination_country_code) == country
        return :standard_ltl
      end

      nil
    end

    def maximum_weight
      Measured::Weight.new(10_000, :pounds)
    end

    def requirements
      %i[account]
    end

    # Documents

    # Rates
    def find_rates(origin, destination, packages, options = {})
      options = @options.merge(options)
      origin = Location.from(origin)
      destination = Location.from(destination)
      packages = Array(packages)

      request = build_rate_request(origin, destination, packages, options)
      parse_rate_response(origin, destination, packages, commit_soap(:rates, request), options)
    end

    # Tracking

    protected

    def build_soap_header(_action)
      {
        authentication_header: {
          user_name: @options[:username],
          password: @options[:password]
        }
      }
    end

    def commit_soap(action, request)
      Savon.client(
        wsdl: request_url(action),
        convert_request_keys_to: :camelcase,
        env_namespace: :soap,
        element_form_default: :qualified
      ).call(
        @conf.dig(:api, :actions, action),
        message: request
      ).body.to_hash
    end

    def request_url(action)
      scheme = @conf.dig(:api, :use_ssl, action) ? 'https://' : 'http://'
      "#{scheme}#{@conf.dig(:api, :domain)}#{@conf.dig(:api, :endpoints, action)}"
    end

    # Documents

    # Rates
    def build_rate_request(origin, destination, packages, options = {})
      options = @options.merge(options)

      accessorials = []
      unless options[:accessorials].blank?
        serviceable_accessorials?(options[:accessorials]) # raises InvalidArgumentError if options[:accessorials] invalid
        options[:accessorials].each do |a|
          unless @conf.dig(:accessorials, :unserviceable).include?(a)
            accessorials << @conf.dig(:accessorials, :mappable)[a]
          end
        end
      end

      longest_dimension = packages.inject([]) { |_arr, p| [p.inches[0], p.inches[1]] }.max.ceil
      if longest_dimension >= 336
        accessorials << 'X29'
      elsif longest_dimension >= 240 && longest_dimensions < 336
        accessorials << 'X28'
      elsif longest_dimension >= 144 && longest_dimensions < 240
        accessorials << 'X20'
      elsif longest_dimension >= 96 && longest_dimensions < 144
        accessorials << 'X12'
      end

      accessorials = accessorials.uniq.join(',')

      shipment_detail = []
      packages.each do |package|
        shipment_detail << "1|#{package.freight_class}|#{package.pounds.ceil}"
      end
      shipment_detail = shipment_detail.join('|')

      {
        customer_code: @options[:account],
        origin_zip: origin.to_hash[:postal_code].to_s.upcase,
        destination_zip: destination.to_hash[:postal_code].to_s.upcase,
        shipment_detail: shipment_detail,
        rating_type: '', # per API documentation
        accessorials: accessorials
      }
    end

    def parse_rate_response(origin, destination, _packages, response, _options = {})
      success = true
      message = ''

      if !response
        success = false
        message = 'API Error: Unknown response'
      else
        # :rate_error itself is unreliable indicator of error as it returns false when there is an error
        if !response.dig(:get_rates_response, :get_rates_result, :rate_error).blank? || response.dig(:get_rates_response, :get_rates_result, :rate_quote_number).blank?
          success = false
          message = response.dig(:get_rates_response, :get_rates_result, :return_line)
        else
          cost = response.dig(:get_rates_response, :get_rates_result, :totals)
          if cost
            cost = cost.sub('$', '').sub('.', '').to_i
            days = response.dig(:get_rates_response, :get_rates_result, :transit_days).to_i
            delivery_range = [days, days]
            estimate_reference = response.dig(:get_rates_response, :get_rates_result, :rate_quote_number)

            rate_estimates = [
              RateEstimate.new(
                origin,
                destination,
                @@name,
                :standard_ltl,
                delivery_range: delivery_range,
                estimate_reference: estimate_reference,
                total_cost: cost,
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

    # Tracking
  end
end
