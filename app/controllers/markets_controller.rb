class MarketsController < ApplicationController
    before_action :authorize, except: [:sign_up, :sign_up_process, :sign_in, :sign_in_process]
    before_action :redirect_to_top_if_signed_in, only: [:sign_up, :sign_in]
    #商品一覧ページ
    def top
        #scopeでキーワード、カテゴリー、価格帯の検索処理を記述
        @products = Product.word_like(params[:word]).category_search(params[:category]).price_search(params[:rangemin], params[:rangemax]).page(params[:page])
        if params[:order].present?
            #並び替え
            case params[:order].to_i
            when 1
                #新しい順
                @products = @products.order("id desc")
            when 2
                #古い順
                @products = @products.order("id asc")
            when 3
                #価格の高い順
                @products = @prducts.order("price desc")
            else
                #価格の安い順
                @products = @products.order("price asc")
            end
        else
            @products = @products.order("id desc")
        end
    end
    
    #商品詳細ページ
    def details
        @product = Product.find_by(id: params[:id])
    end
    
    #商品購入確認ページ
    def payment
        @product = Product.find_by(id: params[:id])
    end
    
    #商品購入処理
    def payment_process
        product = Product.find_by(id: params[:id])
        #購入したので、状態を売り切れにする
        status = 1
        if product.update(status: status)
            flash[:success] = "商品を購入しました"
            redirect_to top_path
        else
            flash[:danger] = "購入できませんでした。"
            redirect_to payment_path(product)
        end
    end
    
end
