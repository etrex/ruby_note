# 綠界物流 ruby 串接
綠界官方做了一個 gem：https://github.com/ECPay/Logistic_RoR

他把東西包裝成 .gem 檔（ecpay_logistics-1.0.7.gem）放在根目錄

也提供了一個[使用說明](https://github.com/ECPay/Logistic_RoR/blob/master/Doc/RoR_ECPay_Logistics_SDK.pdf)

# 官方提供的安裝流程

下載 gem 檔之後，在 bash 輸入：

```
gem install ecpay_logistics-1.0.7.gem
```

這樣做會將 gem 檔安裝到 gem environment 中的 INSTALLATION DIRECTORY，可以使用以下指令查看：

```
gem environment | grep INSTALL
```

不建議這樣安裝。

# 我改過的安裝流程

這是我 unpack 綠界提供的 gem https://github.com/ECPay/Logistic_RoR

之後再修改了 ECpayLogistics::APIHelper 的實作，使得參數可以從 yml 或其他方式傳入

## Install

Gemfile:
```
gem 'ecpay_logistics', github: 'etrex/Logistic_RoR'
```

記得要下 `bundle` 來安裝 gem。

## Config 設定

config/ecpay.yml:
```
# B2C or Home(宅配) 測試帳號
#   operation_mode: Test
#   is_project_contractor: false
#   ignore_payment: [Credit, WebATM, ATM, CVS, Tenpay, TopUpUsed]
#   merchant_id: 2000132
#   hash_key: 5294y06JbISpM5x9
#   hash_iv: v77hoKGq4kWxNNIS
#
# C2C(店到店) 測試帳號
#   operation_mode: Test
#   is_project_contractor: false
#   ignore_payment: [Credit, WebATM, ATM, CVS, Tenpay, TopUpUsed]
#   merchant_id: 2000933
#   hash_key: XBERn1YOvpM9nfZc
#   hash_iv: h1ONHk4P4yqbl5LK

development:
  operation_mode: Test
  is_project_contractor: false
  ignore_payment: [Credit, WebATM, ATM, CVS, Tenpay, TopUpUsed]
  merchant_id: 2000933
  hash_key: XBERn1YOvpM9nfZc
  hash_iv: h1ONHk4P4yqbl5LK

test:
  operation_mode: Test
  is_project_contractor: false
  ignore_payment: [Credit, WebATM, ATM, CVS, Tenpay, TopUpUsed]
  merchant_id: 2000933
  hash_key: XBERn1YOvpM9nfZc
  hash_iv: h1ONHk4P4yqbl5LK

production:
  operation_mode: Test
  is_project_contractor: false
  ignore_payment: [Credit, WebATM, ATM, CVS, Tenpay, TopUpUsed]
  merchant_id: 2000933
  hash_key: XBERn1YOvpM9nfZc
  hash_iv: h1ONHk4P4yqbl5LK
```

config/application.rb:

```
config.ecpay = Rails.application.config_for(:ecpay)
```