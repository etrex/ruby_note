
# order
訂單

# payment_method
付款方式

使用單一表格繼承STI(Single-table inheritance)
使用一個欄位 type 來記錄真正 PaymentMethod 的 class name

有兩種實作方式，一種繼承 PaymentMethod, 另一種是繼承 Gateway

## PaymentMethod
## Spree::Gateway < PaymentMethod
Gateway 是一個轉接器，真正的實作是在 ActiveMerchant 上。

# payments
紀錄每一筆訂單有多少付款

多對多關聯表格 order <-> payment_method

有一個 source 多態欄位可以用來存交易記錄

# credit_cards
一種交易紀錄，
belongs_to payment_methods

