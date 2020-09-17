module ReactiveShipping
  class CTBV < CarrierLogistics
    REACTIVE_FREIGHT_CARRIER = true

    cattr_reader :name
    @@name = 'The Custom Companies'

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

    # Documents

    # Rates
    def build_calculated_accessorials(packages)
      longest_dimension = packages.inject([]) { |_arr, p| [p.inches[0], p.inches[1]] }.max.ceil
      if longest_dimension > 144
        accessorials << '&OL=yes'
      elsif longest_dimension >= 96 && longest_dimension <= 144
        accessorials << '&OL1=yes'
      end
    end

    # Tracking

    # protected

    def conf
      conf_path = File.expand_path('..', __dir__)
      conf_path = File.join(conf_path, 'configuration', 'carriers', "#{self.class.to_s.split('::')[1].downcase}.yml")
      super.deep_merge(YAML.safe_load(File.read(conf_path), permitted_classes: [Symbol]))
    end

    # Documents

    # Rates
  end
end
