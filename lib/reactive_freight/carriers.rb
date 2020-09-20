# frozen_string_literal: true

ReactiveShipping::Carriers.register :BTVP, 'reactive_freight/carriers/btvp'
ReactiveShipping::Carriers.register :DPHE, 'reactive_freight/carriers/dphe'
ReactiveShipping::Carriers.register :PENS, 'reactive_freight/carriers/pens'
ReactiveShipping::Carriers.register :RDFS, 'reactive_freight/carriers/rdfs'
ReactiveShipping::Carriers.register :WRDS, 'reactive_freight/carriers/wrds'

# Carriers based on platforms
ReactiveShipping::Carriers.register :CLNI, 'reactive_freight/carriers/clni'
ReactiveShipping::Carriers.register :CTBV, 'reactive_freight/carriers/ctbv'
ReactiveShipping::Carriers.register :FCSY, 'reactive_freight/carriers/fcsy'
ReactiveShipping::Carriers.register :TOTL, 'reactive_freight/carriers/totl'
