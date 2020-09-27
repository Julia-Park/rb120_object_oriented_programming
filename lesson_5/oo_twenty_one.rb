require 'yaml'

MSG = YAML.load_file('twenty_one_message.yml')

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

  def self.fixed_width_display(rows, widths, first_row_header = false)
    num_columns = number_of_columns(rows)
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

  def clear_screen # clears screen
    system 'clear'
  end
end

class Deck
  SUITS = %w(Diamonds Spades Clubs Hearts)
  RANKS = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace)

  attr_reader :cards

  def initialize
    reset
  end

  def reset
    @cards = []

    RANKS.each do |rank|
      SUITS.each do |suit|
        cards << Card.new(rank, suit)
      end
    end

    cards.shuffle!
  end

  def deal(num) # => array of cards
    cards.pop(num)
  end
end

class Card
  attr_reader :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    rank + ' of ' + suit
  end

  def value
    case rank
    when 'King', 'Queen', 'Jack'  then 10
    when 'Ace'                    then 11
    else                               rank.to_i
    end
  end
end

class Hand
  include Formatting

  attr_reader :cards

  def initialize
    reset
  end

  def total
    cards.reduce(0) do |sum, card|
      value = card.value

      if value == 11 && sum > (Game::BUST_CONDITION - 11)
        sum + 1
      else
        sum + value
      end
    end
  end

  def <<(new_card)
    cards << new_card
  end

  def [](num)
    cards[num]
  end

  def to_s
    joinor(cards, ', ', 'and')
  end

  def reset
    self.cards = []
  end

  private

  attr_writer :cards
end

class Participant
  attr_reader :hand, :name

  def initialize(name)
    @hand = Hand.new
    @name = name
  end

  def draw(cards)
    cards.each do |card|
      hand << card
    end
  end

  def busted?
    hand.total > Game::BUST_CONDITION
  end

  def to_s
    name
  end

  private

  attr_writer :hand
end

class Player < Participant
  include Formatting

  def initialize
    super(choose_name)
  end

  def choose_move
    answer = nil

    loop do
      prompt MSG['choose']
      answer = gets.chomp.downcase
      break if %w(h hit s stay).include?(answer)
      prompt MSG['invalid']
    end

    %(h hit).include?(answer) ? 'hit' : 'stay'
  end

  private

  def choose_name
    answer = nil

    loop do
      prompt MSG['choose_name']
      answer = gets.chomp.capitalize
      break unless answer.empty?
      prompt MSG['invalid_name']
    end

    answer
  end
end

class Dealer < Participant
  def initialize
    super('Dealer')
  end

  def choose_move
    hand.total < Game::DEALER_LIMIT ? 'hit' : 'stay'
  end
end

class Game
  include Formatting

  BUST_CONDITION = 21
  DEALER_LIMIT = 17
  DISPLAY_WIDTH = [76]

  def initialize
    @player = Player.new
    @dealer = Dealer.new
    @deck = Deck.new
    @participants = [player, dealer]
  end

  def start
    loop do
      deal_cards
      player_turn
      dealer_turn
      determine_round_result
      break unless play_again?
      reset
    end

    show_exit_message
  end

  private

  attr_reader :player, :dealer, :deck, :participants

  def reset
    show_welcome_message
    participants.each { |participant| participant.hand.reset }
    deck.reset
  end

  def play_again?
    answer = nil

    loop do
      prompt MSG['play_again']
      answer = gets.chomp.downcase
      break if %w(y yes n no).include?(answer)
      prompt MSG['invalid']
    end

    %w(y yes).include?(answer)
  end

  def determine_round_result
    busted = who_busted

    if !!busted
      show_bust_message(busted)
    elsif player.hand.total == dealer.hand.total
      show_tie_message
    else
      show_outcome_message(who_won)
    end
  end

  def who_won
    participants.max_by { |participant| participant.hand.total }
  end

  def who_busted
    participants.each do |participant|
      return participant if participant.busted?
    end
    nil
  end

  def other_participant(participant)
    participants.select do |other_participants|
      other_participants != participant
    end.first
  end

  def dealer_turn
    return if !!who_busted

    show_dealer_turn_info

    loop do
      move = dealer.choose_move
      move == 'hit' ? hit(dealer) : show_move_choice(dealer, 'stay')
      break if move == 'stay' || dealer.busted?
    end
  end

  def player_turn
    show_player_turn_info

    loop do
      move = player.choose_move
      move == 'hit' ? hit(player) : show_move_choice(player, 'stay')
      break if move == 'stay' || player.busted?
      show_player_turn_info
    end
  end

  def hit(participant)
    show_move_choice(participant, 'hit')
    participant.draw(deck.deal(1))
    show_cards(participant)
  end

  def deal_cards
    player.draw(deck.deal(2))
    dealer.draw(deck.deal(2))
  end

  def hand_totals
    totals = participants.map do |participant|
      format(MSG['total'], player: participant, total: participant.hand.total)
    end

    joinor(totals, ', ', 'and')
  end

  def show_player_turn_info
    clear_screen
    show_welcome_message
    show_turn(player)
    show_initial_cards
  end

  def show_dealer_turn_info
    puts ''
    show_turn(dealer)
    show_cards(dealer)
  end

  def show_outcome_message(participant)
    message =
      [[hand_totals],
       [format(MSG['outcome'], player: participant, num: BUST_CONDITION)],
       [win_message(participant)]]

    fixed_table(message)
  end

  def show_tie_message
    message = [[hand_totals], [MSG['tie']]]

    fixed_table(message)
  end

  def win_message(participant)
    format(MSG['win'], player: participant)
  end

  def show_bust_message(participant)
    message =
      [[hand_totals],
       [format(MSG['bust'], player: participant, num: BUST_CONDITION)],
       [win_message(other_participant(participant))]]

    fixed_table(message)
  end

  def show_cards(participant)
    prompt format(MSG['hand'],
                  player: participant, cards: participant.hand,
                  total: participant.hand.total)
  end

  def show_move_choice(participant, move)
    prompt format(MSG[move], player: participant)
  end

  def show_initial_cards
    prompt format(MSG['hand'],
                  player: player, cards: player.hand,
                  total: player.hand.total)
    prompt format(MSG['hidden_hand'],
                  player: dealer, card: dealer.hand[0])
  end

  def show_welcome_message
    message = [[MSG['welcome']],
               [format(MSG['instructions'], num: BUST_CONDITION)],
               [format(MSG['instructions2'], num: BUST_CONDITION)]]
    fixed_table(message)
  end

  def show_exit_message
    prompt MSG['exit']
  end

  def show_turn(participant)
    puts format(MSG['turn'], player: participant)
  end

  def fixed_table(message)
    Table.fixed_width_display(message, DISPLAY_WIDTH)
  end
end

Game.new.start
