module ApplicationHelper
    #カテゴリーを取得する
    def categories
        if @categories.nil?
            @categories = Category.all
        else
            @categories
        end
    end
end
