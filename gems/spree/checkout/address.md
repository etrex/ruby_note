對 views/spree/checkout/_payment.html.erb
做修改

加入
render views/spree/checkout/_delivery.html.erb

然後調整 delivery 成只有兩個選項，並且讓他在選取項目的切換時可以顯示對應的選項：
  電子地圖
    or
  地址填寫

修改 checkout controller
  增加一個方法去接收 電子地圖傳回的參數


問題：
  當帳單出現異常（沒有辦法運送貨物給客戶）時仍然可以結帳

  Q2:如何處理先填入運送方法，再填入地址的問題？
    spree 預設運送方式選項的生成，會依賴地址資訊。
    根據地址的 zone，選出可以運送到該地址的運送方式列出給客戶選擇。

  A2:

    解法1: 讓地址隱含運送方法。
      若地址隱含運送方法 則可以在後台決定要使用哪一種運送方法，不讓 user 直接選擇運送方式。

      解法1 實作1
        設 zone = 系統中的運送方式 = [宅配, 全家店到店]
        則在地址填寫時，選擇完 zone 後將可以自動選擇出對應的運送方式（只會有一種），就不需要 delivery 階段。

      解法2 實作2
        新增欄位 delivery = 系統中的運送方式 = [宅配, 全家店到店]
        則在地址填寫時，選擇完 delivery 後將可以自動選擇出對應的運送方式（會有多種，必須加code），就不需要 delivery 階段。

    解法2: 不透過spree 預設的運送方式生成機制，直接強制生成運送方式，跳過所有檢查，自己的檢查自己寫。


  假設地址隱含運送方法，如何正確顯示對應運送方法的地址欄位？
    使得每一個運送方法將有一個對應的 view
    若無對應view 則顯示預設view

    填地址的最小需求是firstname、lastname、country
    可在config改為選填的必填欄位：phone
    可在country設定是否為必填欄位：zipcode
    spree 使用 twitter-cldr 作為郵遞區號檢查 https://github.com/twitter/twitter-cldr-rb
  該使用地址欄位中的哪些欄位作為儲存 綠界提供的全家店到店相關資訊 ?

  綠界提供的全家店到店相關資訊範例：
    CVSAddress	台北市南港區三重路１９之４號
    CVSStoreID	001779
    CVSStoreName	工業店
    CVSTelephone	02-24326001

  地址欄位對應：
    firstname: 客戶資料
    lastname: 客戶資料
    address1: CVSAddress
    address2:
    city:
    zipcode: （系統會檢查必填QQ）
    phone: 客戶資料
    state_name:
    alternative_phone:
    company:
    state_id: 同city （可不填）
    country_id: （台灣）
    開新的欄位儲存相關資訊

    shipping_method_id:
    cvs_store_id:
    cvs_store_name: