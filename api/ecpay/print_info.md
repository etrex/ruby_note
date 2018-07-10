# 列印全家店到店繳費單

綠界提供的 API 因為直接產生 html 會導致 html_safe 的問題，所以要拆掉重寫。

使用一個 EcpayExpressesController

.create
.print
.destroy

來對 ECPAY 物流進行操作

新增一個 model EcpayExpress 來儲存相關資訊

若一開始就 create，可能到了要出貨時，訂單早已過期，所以可以考慮在出貨前（print）再作 create。

若在結帳階段時 create ，可能會發現客戶選擇的全家店家不存在或倒閉，使得客戶重新進行結帳流程。

必須要有從後台設定物流資訊的能力（全家地圖的選擇）。

管理者從後台按下列印物流單

express = Express.find_by(order: order)
if express.過期?
  express.destroy
end

if express.nil?
  express = Express.create(order)
end

if express.過期?
  express.destroy
  express = Express.create
end

若 express 未存在或已過期，就新增一個。

使用 express 資訊顯示物流單

根據不同的訂單要使用不同的物流單串接程式


ECPAY Express

  def create
  end
  def print
  end

Ecpay Express model 儲存運送方式