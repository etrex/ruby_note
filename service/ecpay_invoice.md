# Rails 串接 Ecpay 電子發票，就是這麼簡單

這是綠界的電子發票介接技術文件：[綠界科技股份有限公司 電子發票介接技術文件](https://www.ecpay.com.tw/Content/files/ecpay_004.pdf)

根據這份文件，我們可以做的事情有蠻多的，本文只介紹最最基本的功能：
- 開立發票
- 查詢發票明細

本文將會從建立一個新的 Rails App 開始，最後實作開發票和查詢發票明細的功能。

# 建立一個 Rails App

在 console 輸入以下指令：

```bash
rails new ecpay_invoice_demo
cd ecpay_invoice_demo
```

# 新增一個開發票的 service

在專案資料夾中的 `app/services/ecpay/invoice` 資料夾下，新增 `create_service.rb`，此時你應該會發現 app 資料夾下不存在 services 資料夾，你要自己新增資料夾。

在 `create_service.rb` 中加入以下程式碼：

```ruby
module Ecpay
  module Invoice
    class CreateService
      def initialize(params = {})
      end

      def run
        'yo'
      end
    end
  end
end
```

接著在 Rails console 下測試看看

```ruby
> Ecpay::Invoice::CreateService.new.run
# => "yo"
```

看到 yo 代表你做對了。

# 串接綠界API

在這裡我會直接使用綠界提供的測試環境做展示，所以不會實作切換環境的程式碼，以下是綠界的測試環境：

相關連結
- 開立發票的API網址：https://einvoice-stage.ecpay.com.tw/Invoice/Issue
- 綠界測試環境後台登入頁：https://vendor-stage.ecpay.com.tw/Home/Index
- 綠界測試環境電子發票後台：https://vendor-stage.ecpay.com.tw/Einvoice/Index

綠界測試環境後台帳密
- 帳號：StageTest
- 密碼：test1234

API 串接參數
- MerchantID：2000132
- HashKey：ejCk326UnaZWKisg
- HashIV：q9jcZX8Ib9LM8wYk

我們只需要把正確的參數傳進正確的網址，就可以成功開立發票了，現在來修改一下我們的 service code：

```ruby
module Ecpay
  module Invoice
    class CreateService
      def initialize(params = {})
        @params = params
      end

      def run
        create(sample_params)
      end

      private

      def url
        'https://einvoice-stage.ecpay.com.tw/Invoice/Issue'
      end

      def sample_params
        {}
      end

      def create(params)
        uri = URI(url)
        response = Net::HTTP.post_form(uri, params)
        response.body.force_encoding('UTF-8')
      end
    end
  end
end
```

目前的程式碼可以幫我們把 sample_params 傳到綠界，並且獲得回應內容。只要我們再將 sample_params 填入，整個開發票的功能就完成了。現在讓我們回到 Rails console 測試一下目前的程式跑起來是怎樣的結果：

```ruby
> Ecpay::Invoice::CreateService.new.run
 => "無效的MerchantID「商品編號為空白」"
```

我們成功獲得了來自綠界測試環境的錯誤訊息。

# 填入開發票的參數

修改開發票的參數 sample_params 如下：

```ruby
def sample_params
  # 基本參數
  {
    'TimeStamp' => Time.current.to_i.to_s,
    'MerchantID' => '2000132',
    'RelateNumber' => SecureRandom.hex(10), # 訂單編號
    'CustomerEmail' => 'service@5xruby.tw', # 客戶信箱
    'TaxType' => '1', # 課稅類別
    'InvType' => '07', # 字軌類別

  # 商品參數
    'SalesAmount' => 1900, #總金額
    'ItemCount' => '3|2', #商品數量
    'ItemPrice' => '300|500', #商品單價
    'ItemAmount' => '900|1000', #商品小計
    'ItemName' => '衣服|褲子', #商品名稱
    'ItemWord' => '件|件', #商品單位

  # 發票參數
    'Print' => '0', # 要列印嗎？ 0代表不要 1代表要
    'Donation' => '1', # 要捐嗎？ 0代表不要 1代表要
    'LoveCode' => '168001', # 要捐給誰，一個7字元的愛心碼
  }
end
```

試用一下

```ruby
> Ecpay::Invoice::CreateService.new.run
 => "InvoiceDate=&InvoiceNumber=&RandomNumber=&RtnCode=10200090&RtnMsg=CheckMacValue is null.&CheckMacValue=2F3E82F5A5C582BB0E1E5E34EE749F1A"
```
他傳回了一個 query string 來告訴我們發生了什麼事情，我們要關注的地方是 `RtnMsg`。這裡我特寫一下：

```ruby
RtnMsg=CheckMacValue is null.
```

# 計算 CheckMacValue

綠界的回應是說我們沒有傳遞 CheckMacValue 給綠界， CheckMacValue 的功能是用來確認雙方身分用的。我們會把我們要傳遞的參數加入綠界給我們的 HashKey 跟 HashIV，然後進行一個 hash 運算，就可以獲得 CheckMacValue 了。

CheckMacValue 的詳細計算流程如下：
- 將傳遞參數依照第一個英文字母，由 A 到 Z 的順序來排序(遇到第一個英名字母相同時，以第二個英名字母來比較，以此類推)，並且以&方式將所有參數串連。
- 參數最前面加上 HashKey、最後面加上 HashIV
- 將整串字串進行 URL encode
- 轉為小寫
- 使用 MD5 產生雜凑值
- 再轉大寫

由於綠界的 API Server 是用 ASP.NET 實作的，所以我們的 URL encode 的結果必須跟 ASP.NET 上的 URL encode 相同。不同的語言實作的 URL encode 的結果可能會有些微差異，所以我們需要針對這一點特別處理。

全部實作完之後的程式碼如下：

```ruby
require 'net/http'

module Ecpay
  module Invoice
    class CreateService
      def initialize(params = {})
        @params = params
      end

      def run
        create(sample_params)
      end

      private

      def url
        'https://einvoice-stage.ecpay.com.tw/Invoice/Issue'
      end

      def sample_params
        # 基本參數
        {
          'TimeStamp' => Time.current.to_i.to_s,
          'MerchantID' => '2000132',
          'RelateNumber' => SecureRandom.hex(10), # 訂單編號
          'CustomerEmail' => 'service@5xruby.tw', # 客戶信箱
          'TaxType' => '1', # 課稅類別
          'InvType' => '07', # 字軌類別

        # 商品參數
          'SalesAmount' => 1900, #總金額
          'ItemCount' => '3|2', #商品數量
          'ItemPrice' => '300|500', #商品單價
          'ItemAmount' => '900|1000', #商品小計
          'ItemName' => '衣服|褲子', #商品名稱
          'ItemWord' => '件|件', #商品單位

        # 發票參數
          'Print' => '0', # 要列印嗎？ 0代表不要 1代表要
          'Donation' => '1', # 要捐嗎？ 0代表不要 1代表要
          'LoveCode' => '168001', # 要捐給誰，一個7字元的愛心碼
        }
      end

      def create(params)
        params['CheckMacValue'] = compute_check_mac_value(params)
        uri = URI(url)
        response = Net::HTTP.post_form(uri, params)
        response.body.force_encoding('UTF-8')
      end

      def compute_check_mac_value(params)
        # 先將參數備份
        params = params.dup

        # 某些參數需要先進行 url encode
        %w[CustomerName CustomerAddr CustomerEmail].each do |key|
          next if params[key].nil?
          params[key] = urlencode_dot_net(params[key])
        end

        # 某些參數不需要參與 CheckMacValue 的計算
        exclude_keys = %w[InvoiceRemark ItemName ItemWord ItemRemark]
        params = params.reject do |k, _v|
          exclude_keys.include? k
        end

        # 轉成 query_string
        query_string = to_query_string(params)
        # 加上 HashKey 和 HashIV
        query_string = "HashKey=ejCk326UnaZWKisg&#{query_string}&HashIV=q9jcZX8Ib9LM8wYk"
        # 進行 url encode
        raw = urlencode_dot_net(query_string)
        # 套用 MD5 後轉大寫
        Digest::MD5.hexdigest(raw).upcase
      end

      def urlencode_dot_net(raw_data)
        # url encode 後轉小寫
        encoded_data = CGI.escape(raw_data).downcase
        # 調整成跟 ASP.NET 一樣的結果
        encoded_data.gsub!('%21', '!')
        encoded_data.gsub!('%2a', '*')
        encoded_data.gsub!('%28', '(')
        encoded_data.gsub!('%29', ')')
        encoded_data
      end

      def to_query_string(params)
        # 對小寫的 key 排序
        params = params.sort_by do |key, _val|
          key.downcase
        end

        # 組成 query_string
        params = params.map do |key, val|
          "#{key}=#{val}"
        end
        params.join('&')
      end

    end
  end
end
```

試試看結果如何：

```ruby
> Ecpay::Invoice::CreateService.new.run
 => "InvoiceDate=2018-07-19 14:35:02&InvoiceNumber=FX30000137&RandomNumber=8833&RtnCode=1&RtnMsg=開立發票成功&CheckMacValue=D2AEB7BDE6F9ADA94831233A4D0FB2BC"
```

節錄重點：

```ruby
RtnMsg=開立發票成功
InvoiceNumber=FX30000137
```

發票開立成功了！而且我們獲得了發票號碼。

# 發票參數簡介

我把發票參數分為三類：
- 基本參數
- 商品參數
- 發票參數

### 基本參數
- TimeStamp：你的系統的目前時間，綠界會用來做 timeout 檢查
- MerchantID：商店代號，這是綠界發給你的參數
- RelateNumber：在你的電商系統上的訂單編號
- CustomerEmail：買家的mail，如果發票開立成功或中獎，這個信箱有可能會收到信
- TaxType：課稅類別，填 1 代表應稅，填 2 代表零稅率，填 3 代表免稅
- InvType：發票字軌類型，填 07 代表一般稅額， 填 08 代表特種稅額

### 商品參數
- SalesAmount：發票總金額
- ItemCount：商品數量，以 | 做為分隔符號
- ItemPrice：商品單價，以 | 做為分隔符號
- ItemAmount：商品小計，以 | 做為分隔符號
- ItemName：商品名稱，以 | 做為分隔符號
- ItemWord：商品單位，以 | 做為分隔符號

綠界會檢查商品小計的加總必須等於發票總金額

### 發票參數

#### 我要捐發票
如果你這張發票是要捐的，需要傳遞以下參數：
- Print：要列印這張發票嗎？填 0 代表不要，填 1 代表要
- Donation => 要捐嗎？填 0 代表不要，填 1 代表要
- LoveCode => 要捐給誰？填入愛心碼

其中 Print 傳 0，Donation 傳 1。

#### 我要印發票
如果你這張發票是要印的，需要傳遞以下參數：

- Print：1
- Donation：0
- CustomerName：客戶名稱
- CustomerAddr：客戶地址
- CustomerIdentifier：統一編號，此欄位為選填欄位

也就是說，如果你要印，就不能捐。如果你要打統編，就一定要印。即使你必須將客戶名稱跟地址傳給綠界，綠界還是不會幫你印發票寄給客戶。

所以當客戶選擇要印發票時，管理人員則必須要回到綠界電子發票後台去操作列印。

綠界電子發票列印頁網址：https://vendor-stage.ecpay.com.tw/Einvoice/InvoicePrint

#### 我要存發票
如果你不捐，也不印，那麼你要找一個載具來儲存這張電子發票，載具相關參數如下：

- Print：0
- Donation：0
- CarruerType：載具類別，值可能為 1、2、3 其中之一
- CarruerNum：載具編碼

其中 CarruerType 的值的意義如下：
- 1：綠界科技電子發票載具
- 2：自然人憑證號碼
- 3：手機條碼

CarruerNum 的值會在 CarruerType 的值不同而改變其意義，特別的是當 CarruerType 為 1 時，CarruerNum 必須傳遞空字串。

# 微調程式碼

剛剛我們是使用測試資料來開發票，但真正要使用的時候，params 應該是要由外部傳入。

需要修改程式碼如下：

```ruby
def run
  create(@params)
end
```

再 parse 一下輸出：
```ruby
def create(params)
  params['CheckMacValue'] = compute_check_mac_value(params)
  uri = URI(url)
  response = Net::HTTP.post_form(uri, params)
  body = response.body.force_encoding('UTF-8')
  CGI.parse(body).transform_values(&:first)
end
```

測試一下效果

```ruby
params = Ecpay::Invoice::CreateService.new.send(:sample_params)
Ecpay::Invoice::CreateService.new(params).run
 => {"InvoiceDate"=>"2018-07-19 17:11:18", "InvoiceNumber"=>"FX30000163", "RandomNumber"=>"5453", "RtnCode"=>"1", "RtnMsg"=>"開立發票成功", "CheckMacValue"=>"848B5BAF997E316617967BFC09079BA6"}
```

順利～

# 查詢發票明細

一樣，我們建立一個 Ecpay::Invoice::FindService，以下就直接來：

```ruby
require 'net/http'

module Ecpay
  module Invoice
    class FindService
      def initialize(relate_number)
        @relate_number = relate_number
      end

      def run
        find(build_params)
      end

      private

      def url
        'https://einvoice-stage.ecpay.com.tw/Query/Issue'
      end

      def build_params
        {
          'TimeStamp' => Time.current.to_i.to_s,
          'MerchantID' => '2000132',
          'RelateNumber' => @relate_number, # 訂單編號
        }
      end

      def find(params)
        params['CheckMacValue'] = compute_check_mac_value(params)
        uri = URI(url)
        response = Net::HTTP.post_form(uri, params)
        body = response.body.force_encoding('UTF-8')
        CGI.parse(body).transform_values(&:first)
      end

      ...下略 compute_check_mac_value
      
    end
  end
end
```

其實只是修改網址跟換一下參數，查詢發票明細就完成了。現在讓我們來測試一下，測試流程如下：
- 產生測試參數
- 從參數中擷取出訂單編號 relate_number
- 使用參數開立一張發票
- 使用訂單編號做查詢

```ruby
params = Ecpay::Invoice::CreateService.new.send(:sample_params)
relate_number = params["RelateNumber"]
Ecpay::Invoice::CreateService.new(params).run
Ecpay::Invoice::FindService.new(relate_number).run
 => {"IIS_Award_Flag"=>"", "IIS_Award_Type"=>"", "IIS_Carruer_Num"=>"", "IIS_Carruer_Type"=>"", "IIS_Category"=>"B2C", "IIS_Check_Number"=>"", "IIS_Clearance_Mark"=>"", "IIS_Create_Date"=>"2018-07-19 17:14:46", "IIS_Customer_Addr"=>"", "IIS_Customer_Email"=>"service@5xruby.tw", "IIS_Customer_ID"=>"", "IIS_Customer_Name"=>"", "IIS_Customer_Phone"=>"", "IIS_Identifier"=>"0000000000", "IIS_Invalid_Status"=>"0", "IIS_IP"=>"118.163.124.163", "IIS_Issue_Status"=>"1", "IIS_Love_Code"=>"168001", "IIS_Mer_ID"=>"2000132", "IIS_Number"=>"FX30000167", "IIS_Print_Flag"=>"0", "IIS_Random_Number"=>"9234", "IIS_Relate_Number"=>"f633510627a2eddeea0c", "IIS_Remain_Allowance_Amt"=>"", "IIS_Sales_Amount"=>"1900", "IIS_Tax_Amount"=>"0", "IIS_Tax_Rate"=>"0.050", "IIS_Tax_Type"=>"1", "IIS_Turnkey_Status"=>"", "IIS_Type"=>"07", "IIS_Upload_Date"=>"", "IIS_Upload_Status"=>"0", "InvoiceRemark"=>"", "ItemAmount"=>"900|1000", "ItemCount"=>"3|2", "ItemName"=>"衣服|褲子", "ItemPrice"=>"300|500", "ItemRemark"=>"", "ItemTaxType"=>"", "ItemWord"=>"件|件", "PosBarCode"=>"10708FX300001679234", "QRCode_Left"=>"FX3000016710707199234000000000000076c0000000053538851KIjD/jYtIwQXOONltIuFzA==:**********:2:2:1:", "QRCode_Right"=>"**衣服:3:300:褲子:2:500","RtnCode"=>"1", "RtnMsg"=>"查詢發票成功", "CheckMacValue"=>"20F155F2A8CDB994B4EB7B949D98FD9E"}
```

查詢發票成功！值得一提的是發票號碼的 key 變成 `IIS_Number` 了呢～由於篇幅的關係，今天就講到這裡。

因為本次的教學其實根本沒講到 Rails，所以你們要自己實作自己的 Controller 和 Model，並且傳遞正確的參數進入 Service。記得如果想要使用正式環境，就要修改Url、HashKey、HashIV 那些東西哦～重構什麼的自己來齁～

對了，在綠界的測試環境裏只能使用綠界的測試帳號，所以你無法使用你自己註冊的綠界帳號去打綠界的測試環境。你問我「其實綠界有提供 SDK，為什麼你不用？」嗯... 這個不好說阿，但這是一個很棒的問題。