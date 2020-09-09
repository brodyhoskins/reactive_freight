module ReactiveShipping
  class Package
    def cubic_ft(rounded:)
      cubic_ft = (inches[0] * inches[1] * inches[2]).to_f / 1728
      rounded ? ('%0.2f' % cubic_ft).to_f : cubic_ft
    end

    def density(rounded:)
      density = weight.convert_to(:lbs).value.to_f / cubic_ft(rounded: false)
      rounded ? ('%0.2f' % density).to_f : density
    end

    def freight_class
      @options[:freight_class]
    end
  end
end
