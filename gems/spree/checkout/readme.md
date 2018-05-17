# 結帳流程

`/checkout/update/:state` maps to the `Spree::CheckoutController#update` action

所有表單內容都會透過 `Spree::CheckoutController#update` 存入。

# 設定使用者需不需要登入後才能結帳

code：
Spree::Auth::Config[:registration_step]

preference：
allow_guest_checkout


# 設定需不需要在地址填 state （省）
Spree::Config[:address_requires_state]

# 第二隻電話
Spree::Config[:alternative_shipping_phone]

Spree::Config[:alternative_shipping]

# 設定在地址填 Zone 時能選擇的選項
Spree::Config[:checkout_zone]

# 單頁結帳
系統會根據運送地址來決定要用那種物流，所以很難做單頁結帳

Spree assumes the list of shipping methods to be dependent on the shipping address. This is one of the reasons why it is difficult to support single page checkout for customers who have disabled JavaScript.

# 確認結帳頁

預設關閉，可覆寫 Spree::Order 中的 confirmation_required? 方法開啟


# 訂單狀態
由 state machines 管理：https://github.com/state-machines/state_machines

在 Spree::Order::Checkout 中使用了 state_machine。

Spree::Order::Checkout 作為 state_machine 的包裝，提供了以下方法：
- checkout_flow
- go_to_state
- insert_checkout_step
- remove_checkout_step

在 Spree::Order 中使用了 Spree::Order::Checkout 中定義的 checkout_flow

# 訂單狀態更新流程
- user 送出階段表單
- update order 參數
- order.next
- redirect 到下一階段頁面