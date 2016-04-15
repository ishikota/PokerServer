class Player < ApplicationRecord
  validates :name, presence: true
  validates :credential, length: { is: 22 }
end
