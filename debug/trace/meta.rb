# 尋找程式碼的方法

## 給一個 Class，找到他所有方法的實作

class Class
  def methods_source_location(need_ancestors = true)
    methods(need_ancestors).map{|m| method(m).source_location }
  end
end

## 給一個 Module，找到底下所有的 class

module Module
  def classes
    constants.select {|c| const_get(c).is_a? Class}.sort
  end
end




Spree::UsersController.method(:helpers_path).source_location

def
Spree::UsersController.ancestors.select{|c| c.is_a? Class }