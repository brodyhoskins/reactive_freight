Gem::Specification.new do |spec|
  spec.name = 'reactive_freight'
  spec.license = 'MIT'
  spec.version = '0.0.1pre'
  spec.date = '2020-08-08'
  spec.authors = ['Brody Hoskins', 'Sub Pop Records', 'Shopify']
  spec.email = ['brody@brody.digital', 'webmaster@subpop.com' 'integrations-team@shopify.com']

  spec.summary = 'Extend ReactiveShipping to support LTL carriers'
  spec.description = 'ReactiveFreight extends ReactiveShipping to support LTL carriers. Added features include abstracted accessorials and tracking events as well as downloading scanned documents from carriers.'
  spec.homepage = 'https://github.com/brodyhoskins/reactive_freight'

  spec.files = Dir['lib/*.rb']
  spec.files += Dir['[A-Z]*'] + Dir['test/**/*']
  spec.files.reject! { |fn| fn.include? 'CVS' }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.1.2'
  spec.add_development_dependency 'httparty', '~> 0.18'
  spec.add_development_dependency 'reactive_shipping', '~> 3'
  spec.add_development_dependency 'rmagick', '~> 4.1'
  spec.add_development_dependency 'savon', '~> 2'
  spec.add_development_dependency 'watir', '~> 6.1'
  spec.add_development_dependency 'webdrivers', '~> 4.0'
end
