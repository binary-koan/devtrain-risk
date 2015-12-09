# This is a ruby-rewrite of "namegen.py" by Laust Rud Jacobsen (2010).

# From the original source-file (http://www.ailis.de/~k/archives/28-Name-Generator.html)
#
# This class generates names in the quality of the planet names used in
# the classic game Elite. The algorithm used in this class comes from
# the Mote project (http://mote.sourceforge.net/)

class GenerateName
  DIGRAPHS =
    %w(a ac ad ar as at ax ba bi bo ce ci co de di e ed en es ex fa fo ga ge gi
      gu ha he in is it ju ka ky la le le lo mi mo na ne ne ni no o ob oi ol on
      or or os ou pe pi po qt re ro sa se so ta te ti to tu ud um un us ut va
      ve ve za zi)

  TRIGRAPHS =
    %w(cla clu cra cre dre dro pha phi pho sha she sta stu tha the thi thy tri)

  def initialize
    @syllables = random_syllable_count
  end

  def call
    name = generate_name
    name = generate_name until sensible_name?(name)
    name.capitalize
  end

  private

  def generate_name
    name_syllables = (1...@syllables).map { DIGRAPHS.sample }
    name_syllables << (DIGRAPHS + TRIGRAPHS).sample

    name_syllables.join
  end

  def sensible_name?(name)
    name !~ /[aeiou]{3,}/i
  end

  def random_syllable_count
    [2, 3, 4].sample
  end
end
