require 'yaml'

MSG = YAML.load_file('rpsls_messages.yml')

module Table
  CONNECTOR = '+'
  H_SPACER = '-'
  V_SPACER = '|'

  def self.display(rows, first_row_header = false)
    num_columns = number_of_columns(rows)
    widths = column_widths(rows)
    h_line = create_line(widths)
    formatted_rows = rows.map { |row| format_row(row, num_columns, widths) }

    display_rows(formatted_rows, h_line, first_row_header)
  end

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
end

module Formatting
  def self.prompt(message)
    puts ">> " + message
  end
end

class Score
  attr_reader :value

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

  private

  attr_writer :value
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
    system 'clear'
    answer = ''

    loop do
      Formatting.prompt MSG['ask_name']
      answer = gets.chomp
      break unless answer.empty?
      Formatting.prompt MSG['empty_ans']
    end

    @name = answer
  end

  def choose
    choice = nil

    loop do
      Formatting.prompt format(MSG['choose'], choices: Move::VALUES.join(', '))
      choice = gets.chomp.capitalize
      break if Move::VALUES.include?(choice)
      Formatting.prompt MSG['invalid_choice']
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
  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
    @log_heading = ['Round #', player1.name, player2.name, 'Winner']
    @log = []
  end

  def <<(round_history)
    @log << round_history
  end

  def display
    rows = @log.map.with_index do |moves, index|
      [index + 1] + moves
    end

    puts Table.display(rows.prepend(@log_heading), true)
  end

  private

  attr_reader :log, :log_heading, :player1, :player2
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
    @win_against.include?(other_move.value)
  end

  def <(other_move)
    @lose_against.include?(other_move.value)
  end

  protected

  attr_reader :value
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
  YES_NO = ['y', 'yes', 'n', 'no']

  def initialize
    self.human = Human.new
    self.computer = [R2D2, Hal, Chappie, Sonny, Number5].sample.new
    @history = History.new(human, computer)
  end

  def play
    display_welcome_message

    loop do
      player_turns
      round_result
      display_game_winner
      break unless play_again?
      system 'clear'
    end

    display_history
    display_goodbye_message
  end

  private

  attr_accessor :human, :computer
  attr_reader :history

  def display_welcome_message
    system 'clear'
    message = [
      [format(MSG['welcome'],
              game: Move::VALUES.join(', '), player: human.name)],
      [format(MSG['playing_against'], opponent: computer.name)],
      [format(MSG['win_condition'], num: WIN_CONDITION)]
    ]

    Table.display(message)
  end

  def display_goodbye_message
    Formatting.prompt format(MSG['goodbye'], game: Move::VALUES.join(', '))
  end

  def display_moves
    Formatting.prompt format(MSG['move'],
                             player: human.name, move: human.move)
    Formatting.prompt format(MSG['move'],
                             player: computer.name, move: computer.move)
  end

  def update_history(winner_name)
    history << [human.move, computer.move, winner_name]
  end

  def display_winner(winner_name)
    Formatting.prompt format(MSG['won'], player: winner_name)
  end

  def round_result
    winner = round_winner

    if !!winner
      display_winner(winner.name)
      winner.score.increment
      update_history(winner.name)
    else
      Formatting.prompt MSG['tie']
      update_history('Tie')
    end

    display_score
  end

  def round_winner
    if human.move > computer.move
      human
    elsif human.move < computer.move
      computer
    end
  end

  def display_score
    message =
      [[format(MSG['current_score'],
               p1: human.name, p1_score: human.score,
               p2: computer.name, p2_score: computer.score)]]

    Table.display(message)
  end

  def play_again?
    answer = nil

    loop do
      Formatting.prompt MSG['play_again']
      answer = gets.chomp.downcase
      break if YES_NO.include?(answer)
      Formatting.prompt MSG['invalid_choice']
    end

    ['y', 'yes'].include?(answer)
  end

  def display_game_winner
    [human, computer].each do |player|
      if player.winner?
        Formatting.prompt format(MSG['game_winner'],
                                 player: player.name, num: WIN_CONDITION)
        human.score.reset
        computer.score.reset
        break
      end
    end
  end

  def display_history
    answer = nil

    loop do
      Formatting.prompt MSG['see_history']
      answer = gets.chomp.downcase
      break if YES_NO.include?(answer)
      Formatting.prompt MSG['invalid_choice']
    end

    history.display if ['y', 'yes'].include?(answer)
  end

  def player_turns
    human.choose
    computer.choose
    display_moves
  end
end

RPSGame.new.play
