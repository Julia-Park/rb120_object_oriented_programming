require 'yaml'
require 'pry'

MSG = YAML.load_file('ttt_messages.yml')

module TextFormatting
  private

  def prompt(message)
    puts ">> " + message
  end

  def joinor(array, delimiter = ', ', last_delimiter = 'or')
    case array.size
    when 0
      ''
    when 1, 2
      array.join(' ' + last_delimiter + ' ')
    else
      array = array[0..-2] + [last_delimiter + ' ' + array[-1].to_s]
      array.join(delimiter)
    end
  end
end

module SystemMsg
  private

  def clear_screen
    system 'clear'
  end
end

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

class Board
  BORDER = "+-----+-----+-----+"
  EMPTY_ROW = "|     |     |     |"
  SQUARE_ROW = "|  %s  |  %s  |  %s  |"
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # columns
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = Hash.new
    reset
  end

  def display
    puts BORDER
    puts(*row_of_three_squares(1, 2, 3))
    puts BORDER
    puts(*row_of_three_squares(4, 5, 6))
    puts BORDER
    puts(*row_of_three_squares(7, 8, 9))
    puts BORDER
  end

  def reset
    (1..9).each { |key| squares[key] = Square.new }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def []=(key, marker)
    squares[key].marker = marker
  end

  def [](key)
    squares[key].marker
  end

  def unmarked_keys
    squares.keys.select { |key| squares[key].unmarked? }
  end

  def winning_marker # => winning marker or nil
    WINNING_LINES.each do |line|
      markers = line.map { |key| self[key] }.uniq
      return markers.first if markers.size == 1
    end

    nil
  end

  def strategic_square(marker) # => integer or nil if no strategic square exists
    WINNING_LINES.each do |line|
      row_of_markers = line.map { |key| [key, self[key]] }.to_h

      if impending_win?(row_of_markers.values, marker)
        return row_of_markers.key(nil)
      end
    end

    nil
  end

  private

  attr_reader :squares

  def impending_win?(row, marker)
    row.count(marker) == 2 && row.count(nil) == 1
  end

  def row_of_three_squares(position1, position2, position3)
    [EMPTY_ROW,
     format(SQUARE_ROW,
            squares[position1], squares[position2], squares[position3]),
     EMPTY_ROW]
  end
end

class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker

  def initialize(marker = nil)
    @marker = marker
  end

  def to_s
    marker.nil? ? INITIAL_MARKER : marker
  end

  def unmarked?
    marker.nil?
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

  def reset
    self.value = 0
  end

  def increment(num = 1)
    self.value += num
  end

  def ==(num)
    value == num
  end

  private

  attr_writer :value
end

class Player
  attr_reader :marker, :name, :score

  def initialize(name, marker)
    @name = name
    @marker = marker
    @score = Score.new
  end

  def game_winner?
    score == TTTGame::WIN_CONDITION
  end
end

class TTTGame
  MARKERS = %w(X O)
  COMPUTER_NAME = %w(Sam Maxie Taylor Robin Casey)
  WIN_CONDITION = 5
  FIRST_PLAYER = :human

  include TextFormatting, SystemMsg

  def initialize
    @board = Board.new
    @human = Player.new(choose_name, choose_marker)
    @computer = Player.new(COMPUTER_NAME.sample, alt_marker(human.marker))
    reset_current_player
  end

  def play
    clear_screen
    display_welcome_message
    main_game
    display_goodbye_message
  end

  private

  attr_writer :current_player
  attr_reader :board, :human, :computer, :current_player

  def reset_current_player
    self.current_player = (FIRST_PLAYER == :human ? human : computer)
  end

  def alt_marker(other_marker)
    MARKERS.shuffle.select { |marker| marker != other_marker.upcase }.first
  end

  def choose_marker
    answer = nil

    loop do
      prompt MSG['choose_marker']
      answer = gets.chomp
      break if answer.size == 1
      prompt MSG['invalid']
    end

    answer
  end

  def choose_name
    answer = nil

    loop do
      prompt MSG['name']
      answer = gets.chomp
      break unless answer.empty?
      prompt MSG['invalid_name']
    end

    answer
  end

  def main_game
    loop do
      display_board if human_turn?
      player_move
      clear_screen_and_display_board
      round_result
      game_result
      break unless play_again?
      reset_game
      display_play_again_message
    end
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      human_turn? ? display_board : clear_screen
    end
  end

  def current_player_moves
    if human_turn?
      human_moves
      self.current_player = computer
    else
      computer_moves
      self.current_player = human
    end
  end

  def game_winner_message(winner_name)
    format(MSG['game_winner'], name: winner_name, num: WIN_CONDITION)
  end

  def scores_message
    format(MSG['scores'],
           p1: human.name, p1_score: human.score,
           p2: computer.name, p2_score: computer.score)
  end

  def game_winner
    if human.game_winner?
      human.name
    elsif computer.game_winner?
      computer.name
    end
  end

  def game_result
    message = [[scores_message]]

    if !!game_winner
      message << [game_winner_message(game_winner)]
      human.score.reset
      computer.score.reset
    end

    Table.display(message)
  end

  def award_winner(winner)
    winner.score.increment
    display_win_message(winner.name)
  end

  def round_result
    case board.winning_marker
    when human.marker
      award_winner(human)
    when computer.marker
      award_winner(computer)
    else
      display_tie_message
    end
  end

  def display_win_message(winner_name)
    prompt format(MSG['win'], name: winner_name)
  end

  def display_tie_message
    prompt MSG['tie']
  end

  def human_turn?
    current_player == human
  end

  def reset_game
    board.reset
    reset_current_player
    clear_screen
  end

  def play_again?
    answer = nil

    loop do
      prompt MSG['play_again']
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)
      prompt MSG['invalid']
    end

    answer == 'y'
  end

  def display_play_again_message
    prompt MSG['lets_play_again']
  end

  def clear_screen_and_display_board
    clear_screen
    display_board
  end

  def display_board
    display_markers_and_order
    puts ''
    board.display
    puts ''
  end

  def display_welcome_message
    message =
      [[MSG['welcome']], [MSG['instructions']],
       [format(MSG['opponent'], name: computer.name)]]

    Table.display(message)
  end

  def display_goodbye_message
    prompt MSG['goodbye']
  end

  def human_moves
    choices = board.unmarked_keys
    answer = nil

    loop do
      prompt format(MSG['choose_square'], squares: joinor(choices))
      answer = gets.chomp.to_i
      break if choices.include?(answer)
      prompt MSG['invalid']
    end

    board[answer] = human.marker
  end

  def defensive_move
    board.strategic_square(human.marker)
  end

  def offensive_move
    board.strategic_square(computer.marker)
  end

  def computer_choose_key
    if !!offensive_move
      offensive_move
    elsif !!defensive_move
      defensive_move
    elsif board[5].nil?
      5
    else
      board.unmarked_keys.sample
    end
  end

  def computer_moves
    board[computer_choose_key] = computer.marker
  end

  def display_markers_and_order
    prompt format(MSG['markers'],
                  p1_name: human.name, p1_marker: human.marker,
                  p2_name: computer.name, p2_marker: computer.marker,
                  first: FIRST_PLAYER == :human ? human.name : computer.name)
  end
end

game = TTTGame.new
game.play
