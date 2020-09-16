module TextTable
  CONNECTOR = '+'
  H_SPACER = '-'
  V_SPACER = '|'

  def self.number_of_columns(rows) # => integer
    rows.max { |a, b| a.size <=> b.size }.size
  end

  def self.column_widths(rows) # => array of integers
    widths = []

    number_of_columns(rows).times do |column|
      column_content_sizes = rows.map { |row| row[column].to_s.length }
      widths << column_content_sizes.max
    end

    widths
  end

  def self.create_line(column_widths) # => string
    line = column_widths.map { |length| H_SPACER * (length + 2) }
    CONNECTOR + line.join(CONNECTOR) + CONNECTOR
  end

  def self.add_columns(row, add_num) # => array
    array = row.dup
    add_num.times { array << '' }
    array
  end

  def self.justify(row, widths) # => array
    row.map.with_index { |element, i| element.to_s.ljust(widths[i]) }
  end

  def self.format_row(row, num_columns, widths) # => array
    difference = num_columns - row.size
    row = add_columns(row, difference) if difference > 0
    justify(row, widths)
  end

  def self.display_rows(rows, h_line, first_row_header)
    puts h_line # first line

    rows.each.with_index do |row, index|
      puts "#{V_SPACER} #{row.join(' ' + V_SPACER + ' ')} #{V_SPACER}"
      puts h_line if index == 0 && first_row_header
    end

    puts h_line # last line
  end

  def self.display(rows, first_row_header = false)
    num_columns = number_of_columns(rows)
    widths = column_widths(rows)
    h_line = create_line(widths)
    formatted_rows = rows.map { |row| format_row(row, num_columns, widths) }

    display_rows(formatted_rows, h_line, first_row_header)
  end
end

class Score
  attr_accessor :value

  def initialize
    reset
  end

  def to_s
    value.to_s
  end

  def increment(n = 1)
    self.value += n
  end

  def reset
    self.value = 0
  end

  def >=(condition)
    value >= condition
  end
end

class Player
  attr_reader :name, :score, :move

  def initialize
    set_name
    @score = Score.new
  end

  def winner?
    score >= RPSGame::WIN_CONDITION
  end

  def move=(choice)
    @move = case choice
            when 'Rock'     then Rock.new
            when 'Paper'    then Paper.new
            when 'Scissors' then Scissors.new
            when 'Lizard'   then Lizard.new
            when 'Spock'    then Spock.new
            end
  end
end

class Human < Player
  def set_name
    answer = ''

    loop do
      puts "What is your name?"
      answer = gets.chomp
      break unless answer.empty?
      puts "Sorry, must enter a value."
    end

    @name = answer
  end

  def choose
    choice = nil

    loop do
      puts "Please choose #{Move::VALUES.join(', ')}:"
      choice = gets.chomp.capitalize
      break if Move::VALUES.include?(choice)
      puts "Sorry, invalid choice."
    end

    self.move = choice
  end
end

class R2D2 < Player
  def set_name
    @name = 'R2D2'
  end

  def choose
    self.move = 'Rock'
  end
end

class Hal < Player
  def set_name
    @name = 'Hal'
  end

  def choose
    choices = Move::VALUES.map do |value|
      if value == 'Paper'
        [value] * 5
      elsif value == 'Scissors'
        [value]
      else
        [value] * 3
      end
    end.flatten

    self.move = choices.sample
  end
end

class Chappie < Player
  def set_name
    @name = 'Chappie'
  end

  def choose
    self.move = ['Rock', 'Paper', 'Scissors'].sample
  end
end

class Sonny < Player
  def set_name
    @name = 'Sonny'
  end

  def choose
    self.move = Move::VALUES.sample
  end
end

class Number5 < Player
  def set_name
    @name = 'Number 5'
  end

  def choose
    self.move = ['Lizard', 'Spock'].sample
  end
end

class History
  attr_reader :log, :log_heading

  def initialize(player1, player2)
    @log_heading = ['Round #', player1, player2]
    @log = []
  end

  def <<(moves)
    @log << moves
  end

  def display
    rows = @log.map.with_index do |moves, index|
      [index + 1] + moves
    end

    puts TextTable.display(rows.prepend(@log_heading), true)
  end
end

class Move
  VALUES = %w(Rock Paper Scissors Lizard Spock)

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
    @win_against = ['Rock', 'Spock']
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

class RPSGame # Orchestration engine
  WIN_CONDITION = 5

  attr_accessor :human, :computer
  attr_reader :history

  def initialize
    self.human = Human.new
    self.computer = [R2D2, Hal, Chappie, Sonny, Number5].sample.new
    @history = History.new(human.name, computer.name)
  end

  def display_welcome_message
    puts "Welcome to #{Move::VALUES.join(', ')}!"
    puts "Win #{WIN_CONDITION} rounds to win the game!"
    puts "------------------"
  end

  def display_goodbye_message
    puts "Thanks for playing #{Move::VALUES.join(', ')}.  Good bye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def update_score
    if human.move > computer.move
      human.score.increment
    elsif human.move < computer.move
      computer.score.increment
    end
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif human.move < computer.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def display_score
    puts "The current score is #{human.name}: #{human.score} and "\
      "#{computer.name}: #{computer.score}"
  end

  def play_again?
    puts "Do you want to play again? (y/n)"
    answer = nil

    loop do
      answer = gets.chomp.downcase
      break if ['y', 'n'].include?(answer)
      puts "Sorry, must be y or n."
    end

    answer == 'y'
  end

  def display_game_winner
    [human, computer].each do |player|
      if player.winner?
        puts "#{player.name} has reached #{WIN_CONDITION} points.  They win!"
        human.score.reset
        computer.score.reset
        break
      end
    end
  end

  def display_history
    puts "Do you want to see the move history? (y/n)"
    answer = nil

    loop do
      answer = gets.chomp.downcase
      break if ['y', 'n'].include?(answer)
      puts "Sorry, must be y or n."
    end

    history.display if answer == 'y'
  end

  def player_turns
    human.choose
    computer.choose
    history << [human.move, computer.move]
    display_moves
  end

  def play
    display_welcome_message

    loop do
      player_turns
      display_winner
      update_score
      display_score
      display_game_winner
      break unless play_again?
    end

    display_history
    display_goodbye_message
  end
end

RPSGame.new.play
