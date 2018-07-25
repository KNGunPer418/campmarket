class Category < ApplicationRecord
    #リレーション
    has_many :products
end
