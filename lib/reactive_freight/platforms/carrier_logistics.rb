module ReactiveShipping
  class CarrierLogistics < ReactiveShipping::Platform
    ACTIVE_FREIGHT_CARRIER = true

    # Documents

    # Rates

    # Tracking

    # protected

    def build_url(action, options = {})
      scheme = conf.dig(:api, :use_ssl, action) ? 'https://' : 'http://'
      url = "#{scheme}#{conf.dig(:api, :domain)}#{conf.dig(:api, :endpoints, action)}"
      url = url.sub('@CARRIER_CODE@', conf.dig(:api, :carrier_code))
      url << options[:params] unless options[:params].blank?
      url
    end

    def commit(action, _options = {})
      url = build_url(action, params: _options[:params])
      puts "url: #{url}"
      HTTParty.get(url)
    end

    # Documents

    # Tracking

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
          unless conf.dig(:accessorials, :unserviceable).include?(a)
            accessorials << conf.dig(:accessorials, :mappable)[a]
          end
        end
      end

      calculated_accessorials = build_calculated_accessorials(packages)
      params << calculated_accessorials.uniq.join unless calculated_accessorials.blank?
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