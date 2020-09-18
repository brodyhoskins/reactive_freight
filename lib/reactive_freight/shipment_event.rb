# frozen_string_literal: true

module ReactiveShipping
  class ShipmentEvent
    # Return symbol of status rather than a string but maintain compatibility with ReactiveShipping
    def status
      @status ||= name.class == String ? name.downcase.gsub("\s", '_').to_sym : name
    end
  end
end
