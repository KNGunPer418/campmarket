class User < ApplicationRecord
    #リレーション
    has_many :products
    has_many :user_likes
    
    has_secure_password
    #バリデーション
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :name, presence: true
    validates :email, presence: true, format: {with: VALID_EMAIL_REGEX}, uniqueness: true
    validates :password, length: {minimum: 8}, format: {with: /\A(?=.*?[a-z])(?=.*?\d)[a-z\d]+\z/i}
end
