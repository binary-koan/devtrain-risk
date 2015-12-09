class PerformFortify
  MIN_UNITS_ON_TERRITORY   = 1
  MINIMUM_FORTIFYING_UNITS = 1

  attr_reader :validator, :fortify_event

  delegate :errors, to: :validator

  def initialize(**kwargs)
    @validator = ValidateFortify.new(**kwargs)
    @creator   = CreateFortify.new(**kwargs)
    @errors    = []
  end

  def call
    if @validator.call
      @fortify_event = @creator.call
    end

    @fortify_event.present?
  end
end
