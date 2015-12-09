class PerformAttack
  attr_reader :validator, :attack_event

  delegate :errors, to: :validator

  def initialize(**kwargs)
    @validator = ValidateAttack.new(**kwargs)
    @creator   = CreateAttack.new(**kwargs)
    @errors    = []
  end

  def call
    if @validator.call
      @attack_event = @creator.call
    end

    @attack_event.present?
  end
end
