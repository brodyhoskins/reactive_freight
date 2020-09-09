# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'open-uri'
require 'RMagick'
require 'savon'
require 'watir'
require 'webdrivers/chromedriver'
require 'yaml'

require 'reactive_shipping'
require 'reactive_freight/package'
require 'reactive_freight/carrier'
require 'reactive_freight/carriers'
require 'reactive_freight/shipment_event'
