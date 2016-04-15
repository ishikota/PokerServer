FactoryGirl.define do

  factory :player do
    name "kota"
    credential "ek6_UAvyGkc2Hro5Q5lYOA"
  end

  factory :room do
    name "sophian"
    max_round 10
    player_num 3
  end
end

