FactoryGirl.define do

  factory :player do
    name "kota"
    credential "ek6_UAvyGkc2Hro5Q5lYOA"
    uuid "3165ec01-152a-4803-b685-e7f0be8f7bc6"
    online false

    factory "player1" do
      name "poka taro"
      credential 'a' * 22
      uuid "4165ec01-152a-4803-b685-e7f0be8f7bc7"
    end

    factory "player2" do
      name "pokako"
      credential 'b' * 22
      uuid "5165ec01-152a-4803-b685-e7f0be8f7bc8"
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

  factory :game_state do
    state "hogehoge"
  end

end

