require 'yaml'

require 'pry'

MSG = YAML.load_file('twenty_one_message.yml')

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
end

module SystemMsg
  private

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

      if value == 11 && sum > Game::BUST_CONDITION
        sum + 1
      else
        sum + value
      end
    end
  end

  def draw(new_cards)
    self.cards += new_cards
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

  def receive_cards(cards)
    self.hand += cards
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
  def initialize(name)
    super
  end
end

class Dealer < Participant
  def initialize
    super('Dealer')
  end
end

class Game
  include Formatting, SystemMsg

  BUST_CONDITION = 21
  DEALER_LIMIT = 17

  def initialize
    @player = Player.new('some name')
    @dealer = Dealer.new
    @deck = Deck.new
    @participants = [player, dealer]
  end

  def start
    clear_screen
    show_welcome_message

    loop do
      deal_cards
      show_initial_cards
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
      award_winner(other_participant(busted))
    else
      award_winner(who_won)
    end
  end

  def who_won
    participants.max_by { |participant| participant.hand.total }
  end

  def award_winner(participant)
    show_win_message(participant)
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
    loop do
      show_cards(dealer)

      if dealer.hand.total < DEALER_LIMIT
        hit(dealer)
        show_move_choice(dealer, 'hit')
      else
        show_move_choice(dealer, 'stay')
        break
      end
    end
  end

  def player_turn
    loop do
      move = choose_move
      show_move_choice(player, move)    
      hit(player) if move == 'hit'
      break if move == 'stay' || player.busted?
      clear_screen
      show_cards(player)
    end
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

  def hit(participant)
    participant.hand.draw(deck.deal(1))
  end

  def deal_cards
    player.hand.draw(deck.deal(2))
    dealer.hand.draw(deck.deal(2))
  end

  def show_win_message(participant)
    prompt format(MSG['win'], player: participant, num: BUST_CONDITION)
  end

  def show_bust_message(participant)
    prompt format(MSG['bust'], player: participant, num: BUST_CONDITION)
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
    prompt MSG['welcome']
  end

  def show_exit_message
    prompt MSG['exit']
  end
end

Game.new.start
