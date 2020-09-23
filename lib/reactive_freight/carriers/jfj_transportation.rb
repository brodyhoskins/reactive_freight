# frozen_string_literal: true

module ReactiveShipping
  class JFJTransportation < Liftoff
    REACTIVE_FREIGHT_CARRIER = true

    cattr_reader :name
    @@name = 'JFJ Transportation'
  end
end
