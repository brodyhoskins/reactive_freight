module ReactiveShipping
  class Platform < ReactiveShipping::Carrier
    attr_accessor :conf

    def initialize(options = {})
      requirements.each { |key| requires!(options, key) }
      @conf = nil
      @debug = options[:debug].blank? ? false : true
      @options = options
      @last_request = nil
      @test_mode = @options[:test]

      conf_path = File.join(__dir__, 'configuration', 'platforms', 'carrier_logistics.yml')
      @conf = YAML.safe_load(File.read(conf_path), permitted_classes: [Symbol])
    end

    def serviceable_accessorials?(_accessorials)
      raise NotImplementedError, "#{self.class.name}: #serviceable_accessorials not supported"
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