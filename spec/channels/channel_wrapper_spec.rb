require 'rails_helper'

RSpec.describe ChannelWrapper do

  let(:channel) { double("channel") }
  let(:wrapper) { ChannelWrapper.new(channel) }

  describe "#generate_channel" do

    it "should create room channel" do
      channel = wrapper.generate_channel(1)
      expect(channel).to eq 'room:1'
    end

    it "should create player channel" do
      channel = wrapper.generate_channel(1, 1)
      expect(channel).to eq 'room:1:1'
    end

  end

end

