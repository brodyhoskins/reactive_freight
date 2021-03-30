# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'reactive_freight'
  spec.license = 'MIT'
  spec.version = '0.0.2'
  spec.date = '2021-01-07'

  spec.authors = [
    'Brody Hoskins',
    'Sub Pop Records',
    'Shopify'
  ]
  spec.email = [
    'brody@brody.digital',
    'webmaster@subpop.com',
    'integrations-team@shopify.com'
  ]

  spec.summary = 'Extend ReactiveShipping to support LTL carriers'
  spec.description = <<~DESC.gsub(/\n/, ' ').strip
    ReactiveFreight extends ReactiveShipping to support LTL carriers. Added
    features include abstracted accessorials and tracking events as well as
    downloading scanned documents from carriers.
  DESC
  spec.homepage = 'https://github.com/brodyhoskins/reactive_freight'

  spec.files = Dir['lib/**/*']
  spec.files += Dir['[A-Z]*'] + Dir['test/**/*']
  spec.files.reject! { |fn| fn.include? 'CVS' }
  spec.require_paths = ['lib']

  spec.add_dependency 'httparty', '~> 0.10'
  spec.add_dependency 'reactive_shipping', '~> 3.0.0'
  spec.add_dependency 'rmagick', '>= 4.1', '< 4.3'
  spec.add_dependency 'savon', '>= 2.0', '< 2.13'
  spec.add_dependency 'watir', '>= 6.1', '< 6.20'
  spec.add_dependency 'webdrivers', '>= 4.0', '< 4.7'
end
