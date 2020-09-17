module ReactiveShipping
  class CTBV < ReactiveShipping::Carrier
    REACTIVE_FREIGHT_CARRIER = true

    cattr_reader :name
    @@name = 'The Custom Companies'

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
    def find_rates(origin, destination, packages, options = {})
      options = @options.merge(options)
      origin = Location.from(origin)
      destination = Location.from(destination)
      packages = Array(packages)

      params = build_rate_params(origin, destination, packages, options)
      parse_rate_response(origin, destination, packages, commit(:rates, params: params), options)
    end

    # Tracking

    # protected

    def build_url(action, options = {})
      scheme = @conf.dig(:api, :use_ssl, action) ? 'https://' : 'http://'
      url = "#{scheme}#{@conf.dig(:api, :domain)}#{@conf.dig(:api, :endpoints, action)}"
      url << options[:params] unless options[:params].blank?
      url
    end

    def commit(action, _options = {})
      url = build_url(action, params: _options[:params])
      HTTParty.get(url)
    end

    # Documents

    # Rates
    def build_rate_params(origin, destination, packages, _options = {})
      params = ''
      params << "xmlv=yes&xmluser=#{@options[:username]}"
      params << "&xmlpass=#{@options[:password]}"
      params << "&vozip=#{origin.to_hash[:postal_code]}"
      params << "&vdzip=#{destination.to_hash[:postal_code]}"

      i = 0
      packages.each do |package|
        i += 1 # API starts at 1 (not 0)
        params << "&wpieces[#{i}]=1"
        params << "&wpallets[#{i}]=1"
        params << "&vclass[#{i}]=#{package.freight_class}"
        params << "&wweight[#{i}]=#{package.pounds.ceil}"
      end

      accessorials = []
      unless _options[:accessorials].blank?
        serviceable_accessorials?(_options[:accessorials]) # raises InvalidArgumentError if _options[:accessorials] invalid
        _options[:accessorials].each do |a|
          unless @conf.dig(:accessorials, :unserviceable).include?(a)
            accessorials << @conf.dig(:accessorials, :mappable)[a]
          end
        end
      end

      longest_dimension = packages.inject([]) { |_arr, p| [p.inches[0], p.inches[1]] }.max.ceil
      if longest_dimension > 144
        accessorials << '&OL=yes'
      elsif longest_dimension >= 96 && longest_dimension <= 144
        accessorials << '&OL1=yes'
      end

      params << accessorials.uniq.join
      params
    end

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
            rate_estimates = [
              RateEstimate.new(
                origin,
                destination,
                @@name,
                :standard,
                delivery_range: delivery_range,
                estimate_reference: nil,
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
        request: nil
      )
    end
  end
end
