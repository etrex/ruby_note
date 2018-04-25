# 後台 Order 首頁


## 在後台可做的變更
可在後台建立及修改訂單中的幾乎所有項目，除了：
- 訂單狀態無法直接變更

可以用 Adjustment 微調帳單價格，或者做免運，商品被寄出前，系統都會自動做 Adjustment 的調整，如果想要鎖住 Adjustment 的金額，就要用 close adjustment 來上鎖

## 某些情況下客戶會多付錢，可以透過新增 payment 的方式給客戶錢

## State(客戶填單狀態)

- delivery: 這是剛建立的訂單，客戶還在填地址
- complete: 代表客戶該填的表單都填完了

## Payment State(付款狀態)

- Balance Due: 還沒付款

## Shipment State

- Pending: 還在等客戶付款，或者等庫存到貨

預設使用者付款後才能出貨。

### 貨到付款
如果要做貨到付款，可以加入以下程式試試看。

```ruby
Spree::Config[:auto_capture_on_dispatch] = true
```

參考資料：https://stackoverflow.com/questions/38708424/spree-ship-before-confirm-payment?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa

### 運送狀態
無法得知貨送到了沒

### 預購商品（可以先下單再進貨）
如何在庫存數量不足時仍然可以下單？
backorderable 欄位標記商品是否可預購

### 自訂運費計算方式：
寫自己的 Calculator
輸入：整個訂單和要寄出的貨物
輸出：金額

https://guides.spreecommerce.org/developer/calculators.html

# Order Payment
可以從後台的管理介面新增修改刪除多筆付款方式

## 付款方式
- void 代表註銷
- padding 等待付款
- completed 已經付款
- credit owed: 收到超過訂單金額的錢

## SHIPPING METHOD
運送方式，預設為 UPS 的三種到貨速度，每個選項有不同的價格

# Customer
客戶管理頁，可以控制訂單的下單者是誰，
可編輯帳單地址和貨運地址
以及客戶資料中的每一個欄位。

# Adjustments
可以對帳單微調金額。