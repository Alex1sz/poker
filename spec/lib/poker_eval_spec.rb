require "spec_helper"
require "poker_eval"

RSpec.describe Hand do

  describe "One Pair" do

    context "when one pair" do
      before do
        cards = ["2S", "2D", "5S", "7D", "9D"]
        @hand = Hand.new(cards)
      end

      it "#has_same?(2) returns true" do
        expect(@hand.has_same?(2)).to be true
      end

      it "#rank_value is 1" do
        expect(@hand.rank_value).to eq(1)
      end
    end

    context "when no pairs" do

      it "#has_same?(2) returns false" do
        cards = ["2S", "4D", "5S", "6S", "8D"]
        @hand = Hand.new(cards)
        expect(@hand.has_same?(2)).to be false
      end
    end
  end

  describe "Two Pairs" do

    context "when there are two pairs with unique values" do 
      before do
        cards = ["2S", "2D", "4S", "4D", "5D"]
        @hand = Hand.new(cards)
      end

      it "#two_pairs? returns true" do 
        expect(@hand.has_same?(2)).to be true
      end

      it "#rank_value is 2" do
        expect(@hand.rank_value).to eq(2)
      end
    end

    context "when it is not Two Pairs" do

      it "#two_pairs? returns false" do
        cards = ["2S", "4D", "5S", "6S", "8D"]
        @hand = Hand.new(cards)

        expect(@hand.has_same?(2)).to be false
      end
    end
  end

  describe "Three Of A Kind" do

    context "when three cards are of same value" do
      before do
        cards = ["2S", "2S", "2D", "4S", "5S"]
        @hand = Hand.new(cards)
      end

      it "#has_same?(3) returns true" do
        expect(@hand.has_same?(3)).to be true
      end

      it "#rank_value is 3" do
        expect(@hand.rank_value).to eq(3)
      end
    end

    context "when cards do not make three of kind" do

      it "#has_three_same? returns false" do
        cards = ["2S", "2D", "5S", "7D", "9D"]
        @hand = Hand.new(cards)
        expect(@hand.has_same?(3)).to be false
      end
    end
  end

  describe "Flush" do 

    context "when 5 cards of same suit" do

      before do
        cards = ["5S", "4S", "3S", "2S", "2S"]
        @hand = Hand.new(cards)
      end

      # it "#flush returns true" do 
      #   expect(@hand.flush).to be true
      # end

      it "#rank_value is 5" do
        expect(@hand.rank_value).to eq(5)
      end
    end

    # context "when 5 cards are not same suit" do

    #   it "#flush returns false" do
    #     cards = ["2S", "2D", "5S", "7D", "9D"]
    #     @hand = Hand.new(cards)

    #     expect(@hand.flush).to be false 
    #   end
    # end
  end

  describe "Straight" do

    context "when the hand is straight" do

      before do
        cards = ["2S", "3D", "4S", "5D", "6D"]
        @hand = Hand.new(cards)
      end

      it "#straight? returns true" do 
        expect(@hand.consecutive_cards?).to be true
      end

      it "#rank_value is 4" do
        expect(@hand.rank_value).to eq(4)
      end
    end

    context "when the hand is not straight" do

      it "straight? returns false" do
        cards = ["2S", "4D", "5S", "6S", "8D"]
        @hand = Hand.new(cards)

        expect(@hand.consecutive_cards?).to be false
      end
    end
  end

  describe "Full House" do

    context "when the cards make a full house" do

      before do
        cards = ["2S", "2S", "2D", "3S", "3D"]
        @hand = Hand.new(cards)
      end

      it "#full_house? returns true" do
        expect(@hand.has_same?(3) && @hand.has_same?(2)).to be true
      end

      it "#rank_value is 6" do
        expect(@hand.rank_value).to eq(6)
      end
    end

    context "when the cards do not make a full house" do

      it "#full_house returns false" do
        cards = ["2S", "2S", "2D", "6S", "8S"]
        @hand = Hand.new(cards)

        expect(@hand.has_same?(3) && @hand.has_same?(2)).to be false
      end
    end
  end

  describe "Four of a Kind" do

    context "when the cards make 4 of a kind" do

      before do
        cards = ["2S", "2S", "2D", "2D" "5S"]
        @hand = Hand.new(cards)
      end

      it "#has_same?(4) returns true" do
        expect(@hand.has_same?(4)).to be true
      end

      it "#rank_value is 7" do
        expect(@hand.rank_value).to eq(7)
      end

      it "has the #rank of four of a kind" do 
        expect(@hand.rank).to eq( { :type => :four_of_a_kind })
      end
    end

    context "when the cards do not make 4 of a kind" do
      
      it "#has_four_same? returns false" do
        cards = ["2S", "3D", "4S", "5D", "6D"]
        @hand = Hand.new(cards)

        expect(@hand.has_same?(4)).to be false
      end
    end
  end

  describe "Straight Flush" do
    context "when cards make a Straight Flush" do
      before do
        cards = ["2S", "3S", "4S", "5S", "6S"]
        @hand = Hand.new(cards)
      end

      it "#straight_flush returns true" do
        expect(@hand.consecutive_cards? && @hand.suit_count.values.include?(5)).to be true
      end

      it "#rank is straight_flush" do
        expect(@hand.rank).to eq( { :type => :straight_flush } )
      end

      it "#rank_value is 8" do
        expect(@hand.rank_value).to eq(8)
      end
    end

    context "when cards do not make a straight flush" do

      it "#straight_flush returns false" do
        cards = ["2S", "2D", "5S", "7D", "9D"]
        @hand = Hand.new(cards)

        expect(@hand.consecutive_cards? && @hand.suit_count.values.include?(5)).to be false
      end
    end
  end

  describe "Royal Flush" do
    context "when cards make a Royal Flush" do
      before do
        cards = ["TS", "JS", "QS", "KS", "AS"]
        @hand = Hand.new(cards)
      end

      it "#royal_flush returns true" do
        expect(@hand.royal_flush).to be true
      end

      it "has #rank royal flush" do
        expect(@hand.rank).to eq( { :type => :royal_flush } )
      end

      it "#rank_value is 9" do
        expect(@hand.rank_value).to eq(9)
      end
    end

    context "when cards would make make a royal flush except do not in same suit" do
     
      it "#royal_flush returns false" do
        cards = ["10D", "JS", "QS", "KD", "AS"]
        @hand = Hand.new(cards)

        expect(@hand.royal_flush).to be false
      end
    end
  end
end
