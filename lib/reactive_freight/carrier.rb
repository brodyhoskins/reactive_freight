module ReactiveShipping
  class Carrier
    attr_accessor :conf

    def initialize(options = {})
      requirements.each { |key| requires!(options, key) }
      @conf = nil
      @debug = options[:debug].blank? ? false : true
      @options = options
      @last_request = nil
      @test_mode = @options[:test]
      if self.class::REACTIVE_FREIGHT_CARRIER
        conf_path = File.join(__dir__, 'configuration', 'carriers', "#{self.class.to_s.split('::')[1].downcase}.yml")
        @conf = YAML.safe_load(File.read(conf_path), permitted_classes: [Symbol])
      end
    end

    def serviceable_accessorials?(accessorials)
      if !self.class::REACTIVE_FREIGHT_CARRIER || !@conf.dig(:accessorials, :mappable) || !@conf.dig(:accessorials, :unquotable) || !@conf.dig(:accessorials, :unserviceable)
        raise NotImplementedError, "#{self.class.name}: #serviceable_accessorials? not supported"
      end

      serviceable_accessorials = @conf.dig(:accessorials, :mappable).keys + @conf.dig(:accessorials, :unquotable)
      serviceable_count = (serviceable_accessorials & accessorials).size

      unserviceable_accessorials = @conf.dig(:accessorials, :unserviceable)
      unserviceable_count = (unserviceable_accessorials & accessorials).size

      if serviceable_count != accessorials.size || !unserviceable_count.zero?
        raise ArgumentError, "#{self.class.name}: Some accessorials unserviceable"
      end

      true
    end

    def find_bol(_tracking_number, _options = {})
      raise NotImplementedError, "#{self.class.name}: #find_bol not supported"
    end

    def find_estimate(_estimate_reference, _options = {})
      raise NotImplementedError, "#{self.class.name}: #find_estimate not supported"
    end

    def find_pod(_tracking_number, _options = {})
      raise NotImplementedError, "#{self.class.name}: #find_pod not supported"
    end
  end
end
