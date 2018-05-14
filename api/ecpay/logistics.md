# 綠界物流串接

## 文件
[Ecpay 文件入口](https://www.ecpay.com.tw/Service/API_Dwnld)
[ruby 串接](https://github.com/ECPay/Logistic_RoR)
[Ecpay 物流整合API技術文件](https://www.ecpay.com.tw/Content/files/ecpay_030.pdf)

## 各物流商之物流手冊
- 大宗寄倉(B2C)
  - [全家超商：物流進退貨規範手冊](https://www.ecpay.com.tw/Content/files/ecpay_028.pdf)
  - [7-ELEVEN：物流進退貨規範手冊](https://www.ecpay.com.tw/Content/files/ecpay_025.pdf)
  - [萊 爾 富 ：物流進退貨規範手冊](https://www.ecpay.com.tw/Content/files/ecpay_058.pdf)
- 店到店(B2B)
  - [全家超商 ：物流進退貨規範手冊](https://www.ecpay.com.tw/Content/files/ecpay_027.pdf)
  - [7-ELEVEN：物流進退貨規範手冊](https://www.ecpay.com.tw/Content/files/ecpay_026.pdf)
  - [萊 爾 富 ：物流進退貨規範手冊](https://www.ecpay.com.tw/Content/files/ecpay_057.pdf)
- 宅配(Home)
  - [黑貓宅急便：物流進退貨規範手冊](https://www.ecpay.com.tw/Content/files/ecpay_029.pdf)
  - [大嘴鳥宅配通：物流進退貨規範手冊](https://www.ecpay.com.tw/Content/files/ecpay_055.pdf)

## 測試環境
- [測試後台](https://vendor-stage.ecpay.com.tw)

## 測試帳號
根據不同的服務，需要使用不同的測試帳號

### 大宗寄倉(B2C)、宅配(Home)
- 後台帳號：StageTest
- 後台密碼：test1234
- MerchantID：2000132
- HashKey：5294y06JbISpM5x9
- HashIV：v77hoKGq4kWxNNIS

### 店到店(B2B)
- 後台帳號：LogisticsC2CTest
- 後台密碼：test1234
- MerchantID：2000933
- HashKey：XBERn1YOvpM9nfZc
- HashIV：h1ONHk4P4yqbl5LK

## 實際串接測試範例

### 電子地圖串接
此 API 為超商取貨時選擇取貨分店時使用

- 測試環境：https://logistics-stage.ecpay.com.tw/Express/map
- 正式環境：https://logistics.ecpay.com.tw/Express/map

使用者選完分店後，網頁將會被導回 ServerReplyURL，在串接測試時使用 https://etrex-debug.herokuapp.com/http_requests 作為導回的網址，即可直接在網頁上看見導回結果。

#### 大宗寄倉(B2C)統一超商
在瀏覽器輸入以下網址：

https://logistics-stage.ecpay.com.tw/Express/map?MerchantID=2000132&MerchantTradeNo=Ecpay_1234&LogisticsType=CVS&LogisticsSubType=UNIMART&IsCollection=N&ServerReplyURL=https://etrex-debug.herokuapp.com/http_requests&ExtraData=kamigo&Device=0&HashKey=5294y06JbISpM5x9&HashIV=v77hoKGq4kWxNNIS

即可開啟串接頁面，其結果將顯示於 https://etrex-debug.herokuapp.com/http_requests

#### 店到店(B2B)全家
在瀏覽器輸入以下網址：

https://logistics-stage.ecpay.com.tw/Express/map?MerchantID=2000933&MerchantTradeNo=Ecpay_1234&LogisticsType=CVS&LogisticsSubType=FAMIC2C&IsCollection=N&ServerReplyURL=https%3A%2F%2Fetrex-debug.herokuapp.com%2Fhttp_requests%2Fcreate%3Fa%3D1&ExtraData=kamigo&Device=0&HashKey=XBERn1YOvpM9nfZc&HashIV=h1ONHk4P4yqbl5LK

即可開啟串接頁面，其結果將顯示於 https://etrex-debug.herokuapp.com/http_requests


### 物流訂單產生
此 API 為電商結帳後，由電商server 打綠界 server，建立物流出貨單

- 測試環境：https://logistics-stage.ecpay.com.tw/Express/Create
- 正式環境：https://logistics.ecpay.com.tw/Express/Create

使用者選完分店後，網頁將會被導回 ServerReplyURL，在串接測試時使用 https://etrex-debug.herokuapp.com/http_requests 作為導回的網址，即可直接在網頁上看見導回結果。

#### 收貨門市代碼（ReceiverStoreID）
測試環境請使用以下門市進行測試，統一超商：991182、全家：001779、萊爾富：2001。

