# frozen_string_literal: true

module ReactiveShipping
  class CTBV < CarrierLogistics
    REACTIVE_FREIGHT_CARRIER = true

    cattr_reader :name
    @@name = 'The Custom Companies'

    # Documents

    # Rates
    def build_calculated_accessorials(packages, *)
      longest_dimension = packages.inject([]) { |_arr, p| [p.inches[0], p.inches[1]] }.max.ceil
      if longest_dimension > 144
        accessorials << '&OL=yes'
      elsif longest_dimension >= 96 && longest_dimension <= 144
        accessorials << '&OL1=yes'
      end
    end

    # Tracking

    # protected

    # Documents

    # Rates
  end
end
