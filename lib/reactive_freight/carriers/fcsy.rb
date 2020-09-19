# frozen_string_literal: true

module ReactiveShipping
  class FCSY < CarrierLogistics
    REACTIVE_FREIGHT_CARRIER = true

    cattr_reader :name
    @@name = 'Frontline Freight'

    # Documents

    # Rates
    def build_calculated_accessorials(*)
      []
    end

    # Tracking

    # protected

    # Documents

    # Rates
  end
end
