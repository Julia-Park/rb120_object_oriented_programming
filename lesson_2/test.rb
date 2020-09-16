class Move
  VALUES = %w(Rock Paper Scissors Lizard Spock)
  CHOICES = { 'Rock' => Rock, 'Paper' => Paper, 'Scissors' => Scissors}

  def initialize
    @value = to_s
  end

  def to_s
    self.class.to_s
  end

  def >(other_move)
    @win_against.include?(other_move.to_s)
  end

  def <(other_move)
    @lose_against.include?(other_move.to_s)
  end
end

class Rock < Move
  def initialize
    super
    @win_against = ['Scissors', 'Lizard']
    @lose_against = ['Paper', 'Spock']
  end
end

class Scissors < Move
  def initialize
    super
    @win_against = ['Paper', 'Lizard']
    @lose_against = ['Rock', 'Spock']
  end
end

class Paper < Move
  def initialize
    super
    @win_against = ['Rock', 'Paper']
    @lose_against = ['Scissors', 'Lizard']
  end
end

class Lizard < Move
  def initialize
    super
    @win_against = ['Paper', 'Spock']
    @lose_against = ['Scissors', 'Rock']
  end
end

class Spock < Move
  def initialize
    super
    @win_against = ['Rock', 'Scissors']
    @lose_against = ['Paper', 'Lizard']
  end
end

that = CHOICES['Rock']
# this = (Move::CHOICES['Rock']).new

p that
# p this.class
