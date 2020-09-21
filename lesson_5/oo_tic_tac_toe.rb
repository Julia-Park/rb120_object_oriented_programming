require 'yaml'

MSG = YAML.load_file('ttt_messages.yml')

module TextFormatting
  private

  def prompt(message)
    puts ">> " + message
  end
end

module SystemMsg
  private

  def clear_screen
    system 'clear'
  end
end

class Board # represent the state of the board
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

  def unmarked_keys
    squares.keys.select { |key| squares[key].unmarked? }
  end

  def winning_marker # returns winning marker or nil
    WINNING_LINES.each do |line|
      markers = line.map { |key| squares[key].marker }.uniq
      return markers.first if markers.size == 1
    end

    nil
  end

  private

  attr_reader :squares

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

class Player
  attr_reader :marker, :name

  def initialize(name, marker)
    @name = name
    @marker = marker
  end
end

class TTTGame
  MARKERS = %w(X O)
  COMPUTER_NAME = %w(Sam Maxie Taylor Robin Casey)

  include TextFormatting, SystemMsg

  def initialize
    @board = Board.new
    @human = Player.new(get_name, choose_marker)
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

  def alt_marker(other_marker)
    MARKERS.select { |marker| marker != other_marker }.first
  end

  def choose_marker
    answer = nil

    loop do
      prompt format(MSG['marker'], markers: MARKERS.join(', '))
      answer = gets.chomp.upcase
      break if MARKERS.include?(answer)
      prompt MSG['invalid']
    end

    answer
  end

  def get_name
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
      display_board
      player_move
      display_result
      break unless play_again?
      reset_game
      display_play_again_message
    end
  end

  def reset_current_player
    self.current_player = human
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
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
    display_markers
    puts ''
    board.display
    puts ''
  end

  def display_welcome_message
    prompt MSG['welcome']
  end

  def display_goodbye_message
    prompt MSG['goodbye']
  end

  def human_moves
    choices = board.unmarked_keys
    answer = nil

    loop do
      prompt format(MSG['choose'], squares: choices.join(', '))
      answer = gets.chomp.to_i
      break if choices.include?(answer)
      prompt MSG['invalid']
    end

    board[answer] = human.marker
  end

  def computer_moves
    key = board.unmarked_keys.sample
    board[key] = computer.marker
  end

  def display_markers
    prompt format(MSG['markers'],
                  human: human.marker, computer: computer.marker)
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker     then prompt MSG['win']
    when computer.marker  then prompt MSG['lose']
    else                       prompt MSG['tie']
    end
  end
end

game = TTTGame.new
game.play
