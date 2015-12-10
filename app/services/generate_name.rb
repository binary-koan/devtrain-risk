# This is a ruby-rewrite of "namegen.py" by Laust Rud Jacobsen (2010).

# From the original source-file (http://www.ailis.de/~k/archives/28-Name-Generator.html)
#
# This class generates names in the quality of the planet names used in
# the classic game Elite. The algorithm used in this class comes from
# the Mote project (http://mote.sourceforge.net/)

class GenerateName
  VOWELS = %w{a i u e o a i u ei ou ai oi}
  STARTING_CONSONANTS = %w{k s sh t ch n h f m y r w}
  CONTINUING_CONSONANTS = %w{ssh cch nn rr}
  ENDING_CONSONANTS = %w{n m t k}

  THREE_CONSECUTIVE_VOWELS = /[aeiou]{3,}/i
  TWO_PAIRED_LETTERS = /.*(.)\1.*(.)\2/
  OU_PLUS_PAIR = /ou(.)\1/i

  def initialize
  end

  def call
    name = generate_name
    name = generate_name until sensible_name?(name)
    name.capitalize
  end

  private

  def generate_name
    starting_syllables.sample + ending_syllables.sample
  end

  def sensible_name?(name)
    name !~ THREE_CONSECUTIVE_VOWELS && name !~ TWO_PAIRED_LETTERS && name !~ OU_PLUS_PAIR
  end

  def starting_syllables
    VOWELS + basic_syllables
  end

  def ending_syllables
    continuing_syllables + continuing_syllables.product(ENDING_CONSONANTS).map(&:join)
  end

  def continuing_syllables
    basic_syllables + CONTINUING_CONSONANTS.product(VOWELS).map(&:join)
  end

  def basic_syllables
    STARTING_CONSONANTS.product(VOWELS).map(&:join)
  end
end
