# 客製化購物車的顯示

## 先讀懂原本的 code
購物車狀態是由 `_main_nav_bar.html.erb` 這個檔案中的這段程式碼：

```
  <li id="link-to-cart">
    <noscript>
      <%= link_to_cart %>
    </noscript>
    &nbsp;
  </li>
  <script>Spree.fetch_cart()</script>
```

來控制顯示的文字。

如果瀏覽器有開啟 js，那麼就會使用 Spree.fetch_cart() 來抓取資料。

Spree.fetch_cart 是一個 js 函數，被定義在 [spree/frontend/app/assets/javascripts/spree/frontend/cart.js.coffee](https://github.com/spree/spree/blob/25515a467cb208de5d6d950ef25e5db7ba03846f/frontend/app/assets/javascripts/spree/frontend/cart.js.coffee)

```
Spree.fetch_cart = ->
  $.ajax
    url: Spree.pathFor("cart_link"),
    success: (data) ->
      $('#link-to-cart').html data
```

可以從這段 coffee 程式碼中看出，他會向 `/cart_link` 取資料。

從 rails routes 可以發現

GET `/cart_link(.:format)` 是打到 `spree/store#cart_link`

所以我們追到 [Spree::StoreController](https://github.com/spree/spree/blob/7fb31d3c48ab6f414a3af8c5e929b67c46f5527a/frontend/app/controllers/spree/store_controller.rb) 裡面去看：

```
def cart_link
  render partial: 'spree/shared/link_to_cart'
  fresh_when(simple_current_order)
end
```
會發現其實是 render 一個 partial view：`spree/shared/link_to_cart`，把這個 partial view 打開來看會發現：
```
<%= link_to_cart %>
```
這行跟一開始沒開 JS 時要跑的 code 相同：
https://github.com/spree/spree/blob/db3206040f1f04f6031fe305ea4c5046a8b70596/frontend/app/helpers/spree/frontend_helper.rb

```
def link_to_cart(text = nil)
  text = text ? h(text) : Spree.t('cart')
  css_class = nil

  if simple_current_order.nil? || simple_current_order.item_count.zero?
    text = "<span class='glyphicon glyphicon-shopping-cart'></span> #{text}: (#{Spree.t('empty')})"
    css_class = 'empty'
  else
    text = "<span class='glyphicon glyphicon-shopping-cart'></span> #{text}: (#{simple_current_order.item_count})  <span class='amount'>#{simple_current_order.display_total.to_html}</span>"
    css_class = 'full'
  end

  link_to text.html_safe, spree.cart_path, class: "cart-info #{css_class}"
end
```

所以如果要客製化購物車的話要覆寫 `link_to_cart` 這個 helper。

## 開始改 code

覆寫的方法是在 /app/helpers/spree 資料夾下建立一個檔案：frontend_helper_decorator.rb

```
Spree::FrontendHelper.module_eval do
  def link_to_cart(text = nil)
    #在這裡寫你想要的實作
  end
end
```

建議先複製 spree 的 code 來改。