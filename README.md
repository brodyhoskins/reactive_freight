[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop-hq/rubocop)
![stability-wip](https://img.shields.io/badge/stability-work_in_progress-lightgrey.svg)

# ReactiveFreight

ReactiveFreight extends [ReactiveShipping](https://github.com/realsubpop/reactive_shipping) to support LTL carriers.

Features specific to ReactiveFreight:

**Important:** The following features require carriers to be defined as a ReactiveFreight carriers specifically; this means that carriers included with ReactiveShipping function the same as before (and do not inherit the features).

- Abstracted accessorials
- Abstracted tracking events
- Cubic feet and density calculations
- Freight class calculations (and manual overriding)
- Download scanned documents including bill of lading and/or proof of delivery where supported

## Supported Freight Carriers & Platforms

*This list varies day to day as this the project is a work in progress*

**In addition** to the carriers supported by [ReactiveShipping](https://github.com/realsubpop/reactive_shipping), ReactiveFreight supports the following carriers and platforms.

Carriers differ from platforms in that they have unique web services whereas platforms host several carriers' web services on a single service (platform). Carriers however may extend platforms and override them for carrier-specific functionality.

### Carriers

|Carrier                            |BOL|POD|Rates|Tracking|
|-----------------------------------|---|---|-----|--------|
|Best Overnite Express              |✓  |✓  |✓    |✓       |
|Clear Lane Freight Systems         |✓  |✓  |✓    |✓       |
|The Custom Companies               |   |   |✓    |✓       |
|Dependable Highway Express         |   |   |✓    |✓       |
|Forward Air                        |   |✓  |✓    |✓       |
|Frontline Freight                  |✓  |✓  |✓    |✓       |
|Peninsula Truck Lines              |   |   |✓    |        |
|Roadrunner Transportation Services |✓  |✓  |✓    |✓       |
|Saia                               |   |   |✓    |✓       |
|Southeastern Freight Lines         |   |   |✓    |        |
|Tforce Worldwide                   |   |✓  |     |        |
|Total Transportation & Distribution|✓  |✓  |✓    |✓       |
|Western Regional Delivery Service  |   |✓  |     |✓       |

### Platforms

* [Carrier Logistics](https://carrierlogistics.com)

## Versions

[See releases](https://github.com/brodyhoskins/reactive_freight/releases)

## Installation

Using bundler, add to the `Gemfile`:

```ruby
gem 'reactive_freight'
```

Or stand alone:

```
$ gem install reactive_freight
```

## Sample Usage

Start off by initializing the carrier:

```ruby
require 'reactive_freight'
carrier = ReactiveShipping::BTVP.new(account: 'account_number',
                                     username: 'username',
                                     password: 'password')
```

### Documents

```ruby
carrier.find_bol(tracking_number)
carrier.find_pod(tracking_number, path: 'POD.pdf') # path is optional
```

### Tracking

**Important:** When a ReactiveFreight carrier is loaded `ReactiveShipping::ShipmentEvent` objects' `name` and `status` will return symbols rather than text — it is up to higher-level libraries to provide translations.

Carriers included with ReactiveShipping (typically non-freight) will retain the original behavior for compatibility.

```ruby
tracking = carrier.find_tracking_info(tracking_number)

tracking.delivered?
tracking.status

tracking_info.shipment_events.each do |event|
  puts "#{event.name} at #{event.location.city}, #{event.location.state} on #{event.time}. #{event.message}"
end
```

### Quoting

**Note:** Dimensions from ReactiveShipping were passed as an array in `height x width x length` order. While this is still supported, explicitly setting dimensions in a hash (as demonstrated below) is highly recommended to reduce confusion.

```ruby
packages = [
  ReactiveShipping::Package.new(371 * 16,            # 371 lbs
                                {
                                  length: 40,        # inches
                                  width: 48,
                                  height: 47
                                },
                                units: :imperial),
  ReactiveShipping::Package.new(371 * 16,            # 371 lbs
                                {
                                  length: 40,        # inches
                                  width: 48,
                                  height: 47
                                },
                                freight_class: 125,  # override calculated freight class
                                units: :imperial)
]

origin = ReactiveShipping::Location.new(country: 'US',
                                        state: 'CA',
                                        city: 'Los Angeles',
                                        zip: '90001')

destination = ReactiveShipping::Location.new(country: 'US',
                                             state: 'IL',
                                             city: 'Chicago',
                                             zip: '60007')

accessorials = %i[
  appointment_delivery
  liftgate_delivery
  residential_delivery
]

response = carrier.find_rates(origin, destination, packages, accessorials: accessorials)
rates = response.rates
rates = response.rates.sort_by(&:price).collect { |rate| [rate.service_name, rate.price] }
```

**Important:** ReactiveFreight returns a `ReactiveShipping::Carrier` class rather than a string with the carrier's name:

```ruby
rate = rates.first
rate.carrier

=> "Best Overnite Express" # Old output
=> ReactiveShipping::BTVP # New output

# To find the relevant information, check the class
rate.carrier.name
=> "Best Overnite Express"
rate.carrier.scac
=> "BTVP"

# To retain ReactiveShipping behavior
rate.carrier.is_a?(Class) ? carrier.name : carrier
=> "Best Overnite Express"
```