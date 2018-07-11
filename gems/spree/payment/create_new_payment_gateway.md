# 新增一種付款方式的流程

Spree::PaymentMethod 使用單一表格繼承STI(Single-table inheritance)，使用一個欄位 type 來記錄真正 PaymentMethod 的 class name。

付款方式有兩種實作方式，一種是繼承 PaymentMethod，另一種是繼承 Gateway，以下說明繼承 PaymentMethod 的做法。

- 開發階段
  - 實作 PaymentMethod
  - Spree Config 設定
  - 實作 View
- 後台階段
  - 新增付款方式

## 實作 PaymentMethod

跟 Gateway 的方法差不多，實作 PaymentMethod 最快的方法是去複製 Spree::PaymentMethod::Check 的原始碼，然後把 class name 換掉，再加上 method_type，像這樣：

```ruby
module Spree
  class PaymentMethod::EcpayAtm < PaymentMethod
    def actions
      %w{capture void}
    end

    def method_type
      'ecpay_atm'
    end

    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      ['checkout', 'pending'].include?(payment.state)
    end

    # Indicates whether its possible to void the payment.
    def can_void?(payment)
      payment.state != 'void'
    end

    def capture(*)
      simulated_successful_billing_response
    end

    def cancel(*)
      simulated_successful_billing_response
    end

    def void(*)
      simulated_successful_billing_response
    end

    def source_required?
      false
    end

    def credit(*)
      simulated_successful_billing_response
    end

    private

    def simulated_successful_billing_response
      ActiveMerchant::Billing::Response.new(true, '', {}, {})
    end
  end
end
```

放在正確的路徑下：`models/spree/payment_method/ecpay_atm.rb` 就完成了。

## Spree Config 設定

在 `config/initializers/spree.rb` 最後一行加入以下程式碼：

```
Rails.application.config.spree.payment_methods << Spree::PaymentMethod::EcpayAtm
```

加了這行之後，才可以在後台新增付款方式時，找到新增的付款方式。

# 實作 View

Spree 會把所有付款方式對應的 view 都 render 出來，然後在 user 切換付款方式（點擊 radio button）時顯示對應的 view

需要在 views/spree/checkout/payment/ 下新增對應的 view: `_ecpay_atm.html.erb`

## 在後台新增付款方式

http://localhost:3000/admin/payment_methods

新增付款方式後會跳到編輯付款方式的頁面。

其他細節請參考 gateway。