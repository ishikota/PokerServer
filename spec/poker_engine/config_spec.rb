require 'rails_helper'

RSpec.describe Config do

  describe "default value" do

    let(:config) { config = Config.new }

    specify "default initial_stack = 100, max_round = 10, small_blind_amount = 5" do
      expect(config.initial_stack).to eq 100
      expect(config.max_round).to eq 10
      expect(config.small_blind_amount).to eq 5
    end
  end

  describe "attr_accessor" do

    let(:config) { config = Config.new(initial_stack=5, max_round=1, small_blind_amount=10) }

    it "should be writable" do
      expect { config.initial_stack = 10 }.to change{ config.initial_stack }.from(5).to(10)
      expect { config.max_round = 5 }.to change{ config.max_round }.from(1).to(5)
      expect { config.small_blind_amount = 20 }.to change{ config.small_blind_amount }.from(10).to(20)
    end
  end

end

