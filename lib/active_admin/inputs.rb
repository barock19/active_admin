module ActiveAdmin
  module Inputs
    extend ActiveSupport::Autoload

    autoload :DatepickerInput

    autoload :FilterBase
    autoload :FilterStringInput
    autoload :FilterDateRangeInput
    autoload :FilterNumericInput
    autoload :FilterSelectInput
    autoload :FilterCheckBoxesInput
    autoload :FilterBooleanInput

    autoload :BooleanInput
    autoload :DatetimeSelectInput
  end
end
