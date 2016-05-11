require 'rails_helper'

RSpec.describe GameState, :type => :model do

  let(:room) { FactoryGirl.create(:room) }
  let(:state) { "hogehoge" }
  let(:game_state) { GameState.create( state: state ) }
  describe "validation" do

    describe "on state" do
      it "should reject empty state" do
        expect { game_state.state = "" }.to change { game_state.valid? }.to(false)
      end
    end

  end

end
