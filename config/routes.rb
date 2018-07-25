Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #商品系のルーティング
  get '/' => 'markets#top', as: :top
  get 'markets/:id' => 'markets#details', as: :details
  get 'markets/:id/payment' => 'markets#payment', as: :payment
  post 'markets/:id/payment' => 'markets#payment_process'
  #ユーザー処理のルーティング
  get 'users/profiles' => 'users#show', as: :profile
  get 'users/profiles/edit' => 'users#edit', as: :edit
  get 'users/sign_up' => 'users#sign_up', as: :sign_up
  get 'users/sign_in' => 'users#sign_in', as: :sign_in
  get 'users/sign_out' => 'users#sign_out', as: :sign_out
  get 'users/products' => 'users#products', as: :user_product
  get 'users/products/new' => 'users#new', as: :new
  get 'users/products/:id' => 'users#product_detail', as: :product_detail
  get 'users/products/:id/edit' => 'users#product_edit', as: :product_edit
  get 'users/likes' => 'users#likes', as: :likes
  get 'users/likes/:product_id' => "users#likes_process", as: :likes_process
  post 'users/sign_up' => 'users#sign_up_process'
  post 'users/sign_in' => 'users#sign_in_process'
  post 'users/products/new' => "users#exhibit_product"
  post 'users/products/:id/edit' => "users#product_update"
  delete 'users/products/:id/destroy' => 'users#destroy_product', as: :product_destroy
  post 'users/profiles/edit' => "users#user_update"
end
