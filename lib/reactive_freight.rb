# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'open-uri'
require 'rmagick'
require 'savon'
require 'watir'
require 'webdrivers/chromedriver'
require 'yaml'

require 'reactive_shipping'
require 'reactive_freight/package'
require 'reactive_freight/rate_estimate'
require 'reactive_freight/shipment_event'

require 'reactive_freight/carrier'
require 'reactive_freight/platform'

require 'reactive_freight/carriers'
require 'reactive_freight/platforms'

module ReactiveShipping
  def self.all_accessorials
    @all_accessorials ||=
      File.readlines(File.join(File.dirname(__FILE__), '../accessorial_symbols.txt'), chomp: true).map { |s| s.sub(':', '').to_sym }
  end

  def self.all_service_types
    @all_service_types ||=
      File.readlines(File.join(File.dirname(__FILE__), '../service_type_symbols.txt'), chomp: true).map { |s| s.sub(':', '').to_sym }
  end
end