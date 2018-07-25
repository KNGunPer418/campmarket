class Product < ApplicationRecord
  #リレーション
  belongs_to :category
  belongs_to :user
  has_many :user_likes, dependent: :destroy
  
  #バリデーション
  validates :name, presence: true
  validates :description, presence: true
  validates :price, presence: true
  validates :category_id, presence: true
  
  #出品中0、売り切れ1であらわす
  enum status: {exhibit: 0, soldout: 1}
  
  # 1ページあたり6項目表示
  paginates_per 6
  
  #scope
  #wordがあるとき部分一致検索、空のときはallが返る
  scope :word_like, -> (word) {where("name like ?", "%#{word}%") if word.present? } 
  #categoryがあるとき、そのカテゴリーのものを選択する、空のときはallが返る
  scope :category_search, -> (category) {where(category_id: category) if category.present?}
  #rangeminとrangemaxの間でその価格のものを選択する、空のときはallが返る
  scope :price_search, -> (rangemin, rangemax) {where(price: rangemin..rangemax) if rangemin.present? and rangemax.present?}
  
  #お気に入りのステータス状態を返すメソッド
  def likes_from?(user)
    return self.user_likes.exists?(user_id: user.id)
  end
end
