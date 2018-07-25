class UsersController < ApplicationController
    before_action :authorize, except: [:sign_up, :sign_up_process, :sign_in, :sign_in_process]
    before_action :redirect_to_top_if_signed_in, only: [:sign_up, :sign_in]
    #プロフィールページ
    def show
        @user = User.find_by(id: current_user.id)
    end
    
    #ユーザー情報編集ページ
    def edit
        @user = User.find_by(id: current_user.id)
    end
    
    #ユーザー情報更新処理
    def user_update
        upload_file = params[:user][:image]
        #パスワード情報が入力されているか確認
        if params[:user][:password].present? and params[:user][:password_confirmation].present?
            #画像の有無をチェック
            if upload_file.present?
                #画像があるとき
                upload_file_name = upload_file.original_filename
                output_path = Rails.root.join('public', 'users') + upload_file_name
                #更新の可否
                if current_user.update(user_params.merge({image: upload_file_name}))
                    File.open(output_path, "w+b") do |f|
                        f.write(upload_file.read)
                    end
                    flash[:success] = "プロフィールを更新しました"
                    redirect_to profile_path
                else
                    flash[:danger] = "更新に失敗しました"
                    redirect_to edit_path
                end
            else
                #画像がないとき
                if current_user.update(user_params)
                    flash[:success] = "プロフィールを更新しました"
                    redirect_to profile_path
                else
                    flash[:danger] = "更新に失敗しました"
                    redirect_to edit_path
                end
            end
        else
            flash[:danger] = "パスワードが入力されていません"
            redirect_to edit_path
        end
    end
    
    #ユーザー登録ページ
    def sign_up
        @user = User.new
    end
    
    #ユーザー登録処理
    def sign_up_process
        @user = User.new(user_params)
        if @user.save
            #登録に成功したらサインインしてトップページへ
            user_sign_in(@user)
            flash[:success] = "ユーザーを登録しました。"
            redirect_to profile_path
        else
            flash[:danger] = "ユーザー登録に失敗しました"
            render sign_up_path and return
        end
    end
    
    #サインインページ
    def sign_in
        @user = User.new
    end
    
    #サインイン機能
    def sign_in_process
        @user = User.find_by(email: user_params[:email])
        #パスワード認証authenticateメソッド
        if @user && @user.authenticate(user_params[:password])
            #セッション処理
            user_sign_in(@user)
            flash[:success] = "サインインしました"
            redirect_to profile_path
        else
            if @user.nil?
                flash[:danger] = "このユーザは登録されていません"
                redirect_to sign_in_path
            else
                flash[:danger] = "サインインに失敗しました"
                render sign_in_path
            end
        end
    end
    
    #サインアウト機能
    def sign_out
        #ユーザセッションを破棄
        user_sign_out
        flash[:success] = "サインアウトしました"
        redirect_to sign_in_path
    end
    
    #出品ページ
    def new
        @product = Product.new
    end
    
    #出品情報処理
    def exhibit_product
        #画像ファイルのチェック
        upload_files = [params[:product][:image1], params[:product][:image2], params[:product][:image3]]
        #画像ファイル名の取得
        upload_files_name = Array.new
        upload_files.each do |file|
            if file.present?
                upload_files_name << file.original_filename
            else
                upload_files_name << "no_image.jpg"
            end
        end
        #画像ファイルの保存パス
        output_dir = Rails.root.join('public', 'images')
        output_pathes = Array.new
        upload_files_name.each do |name|
            output_pathes << output_dir + name
        end
        #画像ファイルの名前を追加し、Productオブジェクトを作る
        @product = Product.new(product_params.merge({image1: upload_files_name[0], image2: upload_files_name[1], image3: upload_files_name[2]}))
        
        #状態を出品中にする
        @product.status = 0
        
        #データベースに保存
        if @product.save
            #画像ファイルのアップロード
            output_pathes.each_with_index do |path, i|
            #画像ファイルがないときは処理を飛ばす
                if upload_files[i].nil?
                    next
                end
                File.open(path, "w+b") do |f|
                    f.write(upload_files[i].read)
                end
            end
            flash[:success] = "出品しました。"
            redirect_to profile_path
        else
            flash[:danger] = "出品に失敗しました"
            render "users/new" and return
        end
    end
    
    #ユーザの商品ページ
    def products
        user = User.find(current_user.id)
        @products = Product.where(user_id: user.id).page(params[:page])
    end
    
    #ユーザの商品詳細ページ
    def product_detail
        @product = Product.find_by(id: params[:id])
    end
    
    #ユーザの商品詳細編集ページ
    def product_edit
        @product = Product.find_by(id: params[:id])
    end
    
    #ユーザの商品詳細更新処理
    def product_update
        @product = Product.find_by(id: params[:id])
        #現在の画像ファイルネームを取得
        current_image_names = [@product.image1, @product.image2, @product.image3]
         #画像ファイルのチェック
        upload_files = [params[:product][:image1], params[:product][:image2], params[:product][:image3]]
        #画像更新フラグ
        img_flag = false
        #画像ファイル名の取得
        upload_files_name = Array.new
        upload_files.each_with_index do |file, i|
            if file.present?
                #画像の更新があるとき
                  upload_files_name << file.original_filename
                  img_flag = true
            else
                #画像の更新がないとき現在の画像ファイルのまま
                 upload_files_name << current_image_names[i]
            end
        end
        #画像ファイルの保存パス
        output_dir = Rails.root.join('public', 'images')
        output_pathes = Array.new
        upload_files_name.each do |name|
            output_pathes << output_dir + name
        end
        
        if img_flag
            if @product.update(product_params.merge({image1: upload_files_name[0], image2: upload_files_name[1], image3: upload_files_name[2]}))
                #画像ファイルのアップロード
                output_pathes.each_with_index do |path, i|
                #画像ファイルがないときは処理を飛ばす
                    if upload_files[i].nil?
                        next
                    end
                    File.open(path, "w+b") do |f|
                        f.write(upload_files[i].read)
                    end
                end
                flash[:notice] = "商品詳細を更新しました"
                redirect_to product_detail_path(@product)
            else
                flash[:danger] = "更新に失敗しました"
                render "users/product_edit" and return
            end
        else
            if @product.update(product_params)
                flash[:notice] = "商品詳細を更新しました"
                redirect_to product_detail_path(@product)
            else
                flash[:danger] = "更新に失敗しました"
                render "users/product_edit" and return
            end
        end
    end

    #ユーザの出品した商品削除処理
    def destroy_product
        @product = Product.find_by(id: params[:id])
        if @product.destroy
            flash[:success] = "出品した商品を削除しました"
            redirect_to user_product_path
        else
            flash[:danger] = "削除に失敗しました"
            redirect_to product_detail_path(@product)
        end
    end
    
    #お気に入りページ
    def likes
        user = User.find_by(id: current_user.id)
        @products = Product.where(id: UserLike.where(user_id: user.id).pluck(:product_id)).page(params[:page])
    end
    
    #お気に入り登録処理
    def likes_process
        product = Product.find_by(id: params[:product_id])
        #お気に入りのステータスを確認 
        if UserLike.exists?(product_id: product.id, user_id: current_user.id)
            #お気に入り削除 
            UserLike.find_by(product_id: product.id, user_id: current_user.id).destroy
        else
            #お気に入り登録
            UserLike.create(product_id: product.id, user_id: current_user.id)
        end
        redirect_to top_path and return
    end
    
    private
    def user_params
        return params.require(:user).permit(:name, :email, :password, :password_confirmation, :profile)
    end
    
    def product_params
        return params.require(:product).permit(:name, :description, :price, :category_id).merge({user_id: current_user.id})
    end
end
