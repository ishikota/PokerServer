require 'rails_helper'

RSpec.describe Pot do

  let(:pot) { Pot.new }

  describe "#add_chip" do

    it "should append chip to pot" do
      expect { pot.add_chip(5) }.to change { pot.main }.by(5)
    end
  end

  describe "clear" do

    before { pot.add_chip(5) }

    it "should clear the chip" do
      expect { pot.clear }.to change { pot.main }.to(0)
    end
  end

end

