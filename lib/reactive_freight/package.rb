module ReactiveShipping
  class Package
    VALID_FREIGHT_CLASSES = [55, 60, 65, 70, 77.5, 85, 92.5, 100, 110, 125, 150, 175, 200, 250, 300, 400].freeze

    attr_writer :declared_freight_class

    def cubic_ft
      if !inches[0].blank? && !inches[1].blank? && !inches[2].blank?
        cubic_ft = (inches[0] * inches[1] * inches[2]).to_f / 1728
        return ('%0.2f' % cubic_ft).to_f
      end
      nil
    end

    def density
      if !inches[0].blank? && !inches[1].blank? && !inches[2].blank? && pounds
        density = pounds.to_f / cubic_ft
        return ('%0.2f' % density).to_f
      end
      nil
    end

    def calculated_freight_class
      sanitized_freight_class(density_to_freight_class(density))
    end

    def declared_freight_class
      @declared_freight_class || @options[:declared_freight_class]
    end

    def freight_class
      declared_freight_class.blank? ? calculated_freight_class : declared_freight_class
    end

    protected

    def density_to_freight_class(density)
      return nil unless density
      return 400 if density < 1
      return 60 if density > 30

      density_table = [
        [1, 2, 300],
        [2, 4, 250],
        [4, 6, 175],
        [6, 8, 125],
        [8, 10, 100],
        [10, 12, 92.5],
        [12, 15, 85],
        [15, 22.5, 70],
        [22.5, 30, 65],
        [30, 35, 60]
      ]
      density_table.each do |density_row|
        return density_row[2] if (density >= density_row[0]) && (density < density_row[1])
      end
    end

    def sanitized_freight_class(freight_class)
      return nil if freight_class.blank?

      if VALID_FREIGHT_CLASSES.include?(freight_class)
        return freight_class.to_i == freight_class ? freight_class.to_i : freight_class
      end

      nil
    end
  end
end
