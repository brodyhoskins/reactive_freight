# frozen_string_literal: true

module ReactiveShipping
  class CLNI < CarrierLogistics
    REACTIVE_FREIGHT_CARRIER = true

    cattr_reader :name
    @@name = 'Clear Lane Freight Systems'

    # Documents

    # Rates
    def build_calculated_accessorials(packages, origin, destination)
      accessorials = []

      longest_dimension = packages.inject([]) { |_arr, p| [p.inches[0], p.inches[1]] }.max.ceil
      if longest_dimension > 48
        if longest_dimension < 240
          accessorials << '&HHG=yes' # standard overlength fee
        elsif longest_dimension >= 240
          accessorials << '&OVER20=yes'
        elsif longest_dimension >= 192 && longest_dimension < 240
          accessorials << '&OVER16=yes'
        elsif longest_dimension >= 132 && longest_dimension < 192
          accessorials << '&OVER11=yes'
        elsif longest_dimension >= 96 && longest_dimension < 132
          accessorials << '&OVER11=yes'
        end
      end

      if destination.city == 'Boston' && destination.state == 'MA'
        accessorials << '&BOSP=yes'
      end
      if origin.city == 'Boston' && origin.state == 'MA'
        accessorials << '&BOSD=yes'
      end

      if destination.state == 'SD'
        accessorials << '&SDDLY=yes'
      end
      if origin.state == 'SD'
        accessorials << '&SDPU=yes'
      end

      # TODO: Add support for:
      # NYBDY, NYC BUROUGH DELY
      # NYBPU, NYC BUROUGH PU
      # NYLID, NYC LONG ISLAND DELY
      # NYLIP, NYC LONG ISLAND PU
      # NYMDY, NYC MANHATTAN DELY
      # NYMPU, NYC MANHATTAN PU
      # TXWDY, TXWST DELY
      # TXWPU, TXWST PU SURCHARGE

      accessorials
    end

    # Tracking

    # protected

    # Documents

    # Rates
  end
end
