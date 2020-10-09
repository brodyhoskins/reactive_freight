# frozen_string_literal: true

module ReactiveShipping
  class RateEstimate
    attr_accessor :carrier, :charge_items, :compare_price, :currency,
                  :delivery_category, :delivery_date, :delivery_range,
                  :description, :destination, :estimate_reference, :expires_at,
                  :insurance_price, :messages, :negotiated_rate, :origin,
                  :package_rates, :phone_required, :pickup_time, :service_code,
                  :service_name, :shipment_options, :shipping_date,
                  :with_excessive_length_fees

    def initialize(origin, destination, carrier, service_name, options = {})
      self.charge_items = options[:charge_items] || []
      self.compare_price = options[:compare_price]
      self.currency = options[:currency]
      self.delivery_category = options[:delivery_category]
      self.delivery_range = options[:delivery_range]
      self.description = options[:description]
      self.estimate_reference = options[:estimate_reference]
      self.expires_at = options[:expires_at]
      self.insurance_price = options[:insurance_price]
      self.messages = options[:messages] || []
      self.negotiated_rate = options[:negotiated_rate]
      self.origin = origin
      self.destination = destination
      self.carrier = carrier
      self.service_name = service_name
      self.package_rates = if options[:package_rates]
                             options[:package_rates].map { |p| p.update(rate: Package.cents_from(p[:rate])) }
                           else
                             Array(options[:packages]).map { |p| { package: p } }
                           end
      self.phone_required = options[:phone_required]
      self.pickup_time = options[:pickup_time]
      self.service_code = options[:service_code]
      self.shipment_options = options[:shipment_options] || []
      self.shipping_date = options[:shipping_date]
      self.total_price = options[:total_price]
      self.with_excessive_length_fees = options.dig(:with_excessive_length_fees)

      self.delivery_date = @delivery_range.last
    end

    def total_price
      @total_price || @package_rates.sum { |pr| pr[:rate] }
    rescue NoMethodError
      raise ArgumentError, 'RateEstimate must have a total_price set, or have a full set of valid package rates.'
    end
    alias price total_price

    def add(package, rate = nil)
      cents = Package.cents_from(rate)
      if cents.nil? && total_price.nil?
        raise ArgumentError, 'New packages must have valid rate information since this RateEstimate has no total_price set.'
      end

      @package_rates << { package: package, rate: cents }
      self
    end

    def packages
      package_rates.map { |p| p[:package] }
    end

    def package_count
      package_rates.length
    end

    protected

    def delivery_range=(delivery_range)
      @delivery_range = delivery_range ? delivery_range.map { |date| date_for(date) }.compact : []
    end

    def total_price=(total_price)
      @total_price = Package.cents_from(total_price)
    end

    def negotiated_rate=(negotiated_rate)
      @negotiated_rate = negotiated_rate ? Package.cents_from(negotiated_rate) : nil
    end

    def compare_price=(compare_price)
      @compare_price = compare_price ? Package.cents_from(compare_price) : nil
    end

    def currency=(currency)
      @currency = ActiveUtils::CurrencyCode.standardize(currency)
    end

    def phone_required=(phone_required)
      @phone_required = !!phone_required
    end

    def shipping_date=(shipping_date)
      @shipping_date = date_for(shipping_date)
    end

    def insurance_price=(insurance_price)
      @insurance_price = Package.cents_from(insurance_price)
    end

    private

    def date_for(date)
      date && Date.strptime(date.to_s, '%Y-%m-%d')
    rescue ArgumentError
      nil
    end
  end
end
