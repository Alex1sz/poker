#  Hand is Ranked by:
#    High Card:        Highest value card (1)
#    One Pair:         Two cards w/ same value (2)
#    Two Pairs:        Two different pairs (3)
#    Three of a Kind:  Three Cards w/ same value (4)
#    Straight:         5 cards w/ consecutive values. (5)
#    Flush:            5 cards of the same suit (6)
#    Full house:       Three of a kind and a pair (7)
#    Four of a Kind:   Four cards of the same value. (8)
#    Straight Flush:   All cards are consecutive values && of same suit. (9)
#    Royal Flush:      Ten, Jack, Queen, King, Ace, in same suit. (10)

class Card
  attr_accessor :value, :suit

  FACE_VALUES_LOOKUP = {
    'T' => 10,
    'J' => 11,
    'Q' => 12,
    'K' => 13,
    'A' => 14
  }

  def initialize(str)
    if FACE_VALUES_LOOKUP.key?(str[0])
      @value = FACE_VALUES_LOOKUP.fetch(str[0])
    else
      @value = str[0].to_i
    end
    @suit = str[1]
  end

  def to_s
    @value.to_s + @suit.to_s
  end
end

class Hand
  attr_accessor :cards

  RANKS = [
    :high_card,
    :one_pair, 
    :two_pairs,
    :three_of_a_kind, 
    :straight,
    :flush, 
    :full_house, 
    :four_of_a_kind, 
    :straight_flush,
    :royal_flush,
  ]

  def rank_value
    RANKS.index(rank.fetch(:type))
  end

  def initialize(cards)
    @cards = cards.map { |card| card.is_a?(Card) ? card : Card.new(card) }
  end

  HAND_RANKS = [
    { :type => :royal_flush,     hand_has?: ->(hand){ hand.royal_flush } },
    { :type => :straight_flush,  hand_has?: ->(hand){ hand.consecutive_cards? && hand.suit_count.values.include?(5) } },
    { :type => :four_of_a_kind,  hand_has?: ->(hand){ hand.has_same?(4) } },
    { :type => :full_house,      hand_has?: ->(hand){ hand.has_same?(3) && hand.has_same?(2) } },
    { :type => :straight,        hand_has?: ->(hand){ hand.consecutive_cards? } },
    { :type => :flush,           hand_has?: ->(hand){ hand.suit_count.values.include?(5) } },
    { :type => :three_of_a_kind, hand_has?: ->(hand){ hand.has_same?(3) } },
    { :type => :two_pairs,       hand_has?: ->(hand){ hand.collapsed_size == 2 && hand.has_same?(2) } },
    { :type => :one_pair,        hand_has?: ->(hand){ hand.has_same?(2) } },
    { :type => :high_card,       hand_has?: ->(hand){ true } }
  ]

  def rank
    unless @cards.empty?
      hand = self
      rank = HAND_RANKS.find { |rank| rank[:hand_has?].call(hand) }.select { |k, v| k == :type }
    end
  end

  def value_count
    grouped_cards = @cards.map(&:value).group_by { |i| i }
    grouped_cards.each do |key, val|
      grouped_cards[key] = val.count
    end
  end

  def suit_count
    grouped_cards = @cards.map(&:suit).group_by { |i| i }
    grouped_cards.each do |key, value|
      grouped_cards[key] = value.count
    end
  end

  def to_s
    @cards.map { |card| card.to_s }.join(',')
  end

  def has_same?(n)
    value_count.values.include?(n)
  end

  def consecutive_cards?
    card_values = @cards.map { |card| card.value }.sort
    difference_always_1 = true
    i = 0

    while difference_always_1 && i < 4 do
      difference_between_values = card_values[i + 1] - card_values[i]
      difference_always_1 = difference_between_values == 1
      i += 1
    end
    difference_always_1
  end

  def royal_flush
    royal_values = [10, 11, 12, 13, 14]
    card_values = @cards.map { |card| card.value }.sort
    card_values == royal_values && suit_count.values.include?(5)
  end

  def high_card
    sorted_cards = @cards.sort_by(&:value)
    sorted_cards[sorted_cards.length-1].value
  end

  def collapsed_size
    all_cards = @cards.map(&:value)
    all_cards.length - all_cards.uniq.length
  end

  def repeated_values
    @cards.group_by(&:value).map { |value, repeats| [value.to_i, repeats.count ]}.reject { |value, count| count == 1 }.sort_by { |value, count | [count, value] }.reverse.map(&:first)[0]
  end

  def tiebreaker
    rank_value >= 1 ? repeated_values : high_card
  end
end

class Player
  def initialize(wins)
    @wins = wins
  end

  def wins=(w)
    @wins = w
  end

  def wins
    @wins
  end
end

module Poker

  def self.evaluate_by_tiebreaker(h1, h2)
    if h1.tiebreaker > h2.tiebreaker
      puts "\n Wins by tiebreaker@player_1.wins += 1: Player_1 H: #{h1} #{h1.rank} Tiebreaker: #{h1.tiebreaker} ..... Loser: P2 H: #{h2} #{h2.rank} Tiebreaker: #{h2.tiebreaker}"
      1
    else
      puts "\n Wins by tiebreaker: Player_2 H: #{h2} #{h2.rank} Tiebreaker: #{h2.tiebreaker} ..... Loser: P1 H: #{h1} #{h1.rank} Tiebreaker: #{h1.tiebreaker}"
      2
    end
  end

  def self.evaluate_by_handrank(h1, h2)
    if h1.rank_value > h2.rank_value
      puts "\n Winner: Player_1 H: #{h1} #{h1.rank} ..... Loser: P2 H: #{h2} #{h2.rank}"
      1
    else
      puts "\n Winner: Player_2 H: #{h2} #{h2.rank} ..... Loser: P1 H: #{h1} #{h1.rank}"
      2
    end
  end

  def self.winning_hand(h1, h2)
    h1.rank_value == h2.rank_value ? evaluate_by_tiebreaker(h1, h2) : evaluate_by_handrank(h1, h2)
  end
end

@player_1 = Player.new(0)
@player_2 = Player.new(0)

f = File.open('./poker.txt').each_line do |line|
  two_hands = line.split(/\W/)
  Poker::winning_hand(Hand.new(two_hands[0..4]), Hand.new(two_hands[5..9])) == 1 ? @player_1.wins += 1 : @player_2.wins += 1
end
puts "Player_1 Wins: #{@player_1.wins} ... Player_2 Wins: #{@player_2.wins}"

