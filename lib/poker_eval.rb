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

module Poker

  def self.handranks_tie?(h1, h2)
    h1.rank_value == h2.rank_value
  end

  def self.evaluate_by_tiebreaker(h1, h2)
    if h1.tiebreaker > h2.tiebreaker
      puts "\n Wins by Tiebreaker: Player_1 H: #{h1} #{h1.rank} Tiebreaker: #{h1.tiebreaker} ..... Loser: P2 H: #{h2} #{h2.rank} Tiebreaker: #{h2.tiebreaker}"
    else
      puts "\n Wins by Tiebreaker: Player_2 H: #{h2} #{h2.rank} Tiebreaker: #{h2.tiebreaker} ..... Loser: P1 H: #{h1} #{h1.rank} Tiebreaker: #{h1.tiebreaker}"
    end
  end

  def self.evaluate_by_handrank(h1, h2)
    if h1.rank_value > h2.rank_value
      puts "\n Winner: Player_1 H: #{h1} #{h1.rank} ..... Loser: P2 H: #{h2} #{h2.rank}"
    else
      puts "\n Winner: Player_2 H: #{h2} #{h2.rank} ..... Loser: P1 H: #{h1} #{h1.rank}"
    end
  end

  def self.winning_hand(h1, h2)
    if handranks_tie?(h1, h2)
      evaluate_by_tiebreaker(h1, h2)
    else
      evaluate_by_handrank(h1, h2)
    end
  end
end

class Card
  attr_accessor :value, :suit

  SUITS_LOOKUP = {
    'C' => :clubs,
    'D' => :diamonds,
    'H' => :heart,
    'S' => :spades
  }

  FACE_VALUES_LOOKUP = {
    'T' => 10,
    'J' => 11,
    'Q' => 12,
    'K' => 13,
    'A' => 14
  }

  def initialize(str)
    val = str[0]

    if FACE_VALUES_LOOKUP.key?(val)
      @value = FACE_VALUES_LOOKUP.fetch(val)
    else
      @value = val.to_i
    end
    @suit = str[1]
  end

  def to_s
    @value.to_s + @suit.to_s
  end
end

class Hand
  include Poker
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
    { :type => :straight_flush,  hand_has?: ->(hand){ hand.straight_flush } },
    { :type => :four_of_a_kind,  hand_has?: ->(hand){ hand.has_same?(4) } },
    { :type => :full_house,      hand_has?: ->(hand){ hand.full_house? } },
    { :type => :straight,        hand_has?: ->(hand){ hand.straight? } },
    { :type => :flush,           hand_has?: ->(hand){ hand.flush } },
    { :type => :three_of_a_kind, hand_has?: ->(hand){ hand.has_same?(3) } },
    { :type => :two_pairs,       hand_has?: ->(hand){ hand.collapsed_size == 2 && hand.has_same?(2) } },
    { :type => :one_pair,        hand_has?: ->(hand){ hand.has_same?(2) } },
    { :type => :high_card,       hand_has?: ->(hand){ true } }
  ]

  def rank
    unless empty?
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

  def empty?
    @cards.empty?
  end

  def to_s
    cards_array = @cards.map { |card| card.to_s }
    cards_array.join(',')
  end

  def has_same?(n)
    value_count.values.include?(n)
  end

  def two_pairs?
    collapsed_size == 2 && has_same?(2)
  end

  def full_house?
    has_same?(3) && has_same?(2)
  end

  def flush
    suit_count.values.include?(5)
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

  def straight?
    consecutive_cards?
  end

  def straight_flush
    if straight? && flush
      true
    else
      false
    end
  end

  def royal_flush
    royal_values = [10, 11, 12, 13, 14]
    card_values = @cards.map { |card| card.value }.sort

    if card_values == royal_values && flush
      true
    else
      false
    end
  end

  def high_card
    sorted_cards = @cards.sort_by(&:value)
    i = sorted_cards.length - 1
    sorted_cards[i].value
  end

  def collapsed_size
    all_cards = @cards.map(&:value)
    all_cards_size = all_cards.length
    unique = all_cards.uniq.length
    all_cards_size - unique
  end

  def repeats
    @cards.group_by(&:value)
  end

  def repeated_values
    repeated = repeats.map { |value, repeats| [value.to_i, repeats.count ]}
    repeated = repeated.reject { |value, count| count == 1 }
    repeated = repeated.sort_by { |value, count | [count, value] }.reverse
    repeated = repeated.map(&:first)
    repeated[0]
  end

  def tiebreaker
    if rank_value >= 1
      repeated_values
    else
      high_card
    end
  end
end

@player_one_wins = 0
@player_two_wins = 0

f = File.open('./poker.txt').each_line do |line|
  two_hands = line.split(/\W/)
  h1 = Hand.new(two_hands[0..4])
  h2 = Hand.new(two_hands[5..9])
  Poker::winning_hand(h1, h2)

    if h1.rank_value > h2.rank_value
      @player_one_wins += 1
    elsif h2.rank_value > h1.rank_value
      @player_two_wins += 1
    elsif h1.rank_value == h2.rank_value && h1.tiebreaker > h2.tiebreaker
      @player_one_wins += 1
    elsif h1.rank_value == h2.rank_value && h1.tiebreaker < h2.tiebreaker
      @player_two_wins += 1
    end
  end
  puts f
  puts "Player_1 Wins: #{@player_one_wins} ... Player_2 Wins: #{@player_two_wins}"

