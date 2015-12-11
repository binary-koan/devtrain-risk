class PerformAttack
  attr_reader :validator, :attack_events

  delegate :errors, to: :validator

  def initialize(**kwargs)
    @validator = ValidateAttack.new(**kwargs)
    @creator   = CreateAttack.new(**kwargs)
    @errors    = []
  end

  def call
    if @validator.call
      @attack_events = @creator.call
    end

    unless @attack_events.present?
      @errors << :unable_to_attack
    end

    @attack_events.present? && @attack_events.any?
  end
end
