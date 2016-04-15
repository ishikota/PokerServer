FactoryGirl.define do

  factory :player do
    name "kota"
    credential "ek6_UAvyGkc2Hro5Q5lYOA"

    factory "player1" do
      name "poka taro"
      credential 'a' * 22
    end

    factory "player2" do
      name "pokako"
      credential 'b' * 22
    end

  end

  factory :room do
    name "sophian"
    max_round 10
    player_num 3

    factory :room1 do
      name "popopo"
      max_round 2
      player_num 2
    end

    factory :room2 do
      name "kakaka"
      max_round 5
      player_num 8
    end

  end
end

