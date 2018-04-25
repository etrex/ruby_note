# 新增一種付款方式的流程

Spree::PaymentMethod 使用單一表格繼承STI(Single-table inheritance)，使用一個欄位 type 來記錄真正 PaymentMethod 的 class name。

付款方式有兩種實作方式，一種是繼承 PaymentMethod，另一種是繼承 Gateway，以下說明繼承 Gateway 的做法。

- 開發階段
  - 實作 ActiveMerchant
  - 實作 Gateway
  - Spree Config 設定
  - 實作 View
- 後台階段
  - 新增付款方式

## 實作 ActiveMerchant
ActiveMerchant 是將金流包裝成統一的介面。

需要提供6個方法

- purchase
- authorize
- capture
- credit
- void
- cancel

在每一個方法打出 https request 到金流商，並且以 ActiveMerchant 定義的格式傳回結果。

## Authorize
這其中最重要的方法是 authorize，以信用卡刷卡來說，刷卡當下不代表扣款，真正的扣款是發生在 capture。當一個 user 從購物車按結帳，填完付款資訊送出後，就是打到 authorize。

我們要繼承 ActiveMerchant::Billing::TappayGateway，寫一個自己的 ActiveMerchant Gateway。


## 實作 Gateway

Spree 本身有一個 PaymentMethod 類別，這是一個 Model，有對應的資料庫表格(spree_payment_methods)。

## Autocapture
當 PaymentMethod 的 autocapture = true ，結帳時會呼叫 PaymentMethod 中的 purchase
當 PaymentMethod 的 autocapture = false ，結帳時會呼叫 PaymentMethod 中的 authorize
一個成功的 purchase 會讓 payment state 變成 completed
一個成功的 authorize 會讓 payment state 變成 padding
在 padding 狀態呼叫 capture 會讓 payment state 變成 completed

### Preference

在表格中有一個欄位 preference，可以用來儲存一些設定值，像是串接時需要的金鑰等。

我們可以定義我們需要哪些設定值，就像是宣告變數，只要在 class 內寫入以下程式：

```ruby
preference :appid, :string
```

就等於定義一個設定值叫做 appid。

### provider_class

Spree::Gateway 繼承 PaymentMethod，可以說是一個從 Spree 到 ActiveMerchant 的轉接頭，讓 Spree 能串接 ActiveMerchant。

我們繼承 Spree::Gateway，所以我們需要在 provider_class 方法定義會轉接到哪個 ActiveMerchant：

```ruby
def provider_class
  ActiveMerchant::Billing::TappayGateway
end
```

### 程式追追追

在 Spree::Gateway 定義了一個方法：`options`，可以將 preferences 欄位的值讀出來。

```
def options
  preferences.each_with_object({}) { |(key, value), memo| memo[key.to_sym] = value; }
end
```

然後再傳給我們實作的 provider，也就是 ActiveMerchant。

```
def provider
  gateway_options = options
  gateway_options.delete :login if gateway_options.key?(:login) && gateway_options[:login].nil?
  if gateway_options[:server]
    ActiveMerchant::Billing::Base.mode = gateway_options[:server].to_sym
  end
  @provider ||= provider_class.new(gateway_options)
end
```

可以看到最後一行 `provider_class.new(gateway_options)`，在建構 provider_class 時會將 gateway_options 傳入。

### payment_profiless

spree 支援系統保存付款資訊，這可以用來做下次付款，或者退款等後續操作。

```
def payment_profiles_supported?
  true
end

def create_profile

end
```

## Spree Config 設定

在 `config/initializers/spree.rb` 最後一行加入以下程式碼：

```
Rails.application.config.spree.payment_methods << Spree::Gateway::Tappay
```

加了這行之後，才可以在後台新增付款方式時，找到新增的付款方式。

# 實作 View

Spree 會把所有付款方式對應的 view 都 render 出來，然後在 user 切換付款方式（點擊 radio button）時顯示對應的 view

需要在 views/spree/checkout/payment/ 下新增對應的 view

## 在後台新增付款方式

http://localhost:3000/admin/payment_methods

新增付款方式後會跳到編輯付款方式的頁面，此時可以填入 preference 的值，他們會被存進 spree_payment_methods 表格中的 preferences 欄位。

這些 preferences 值會變成 gateway_options，在 spree 呼叫 gateway method 時作為參數被傳進去。