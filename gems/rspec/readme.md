## RSpec 簡介

這是一個用來做自動測試的套件

## 新增測試

新增測試的generator語法：

```bash
rails generate rspec:model user
```

這樣寫會建立一個檔案在 spec/models/user_spec.rb

## 簡單的範例

```ruby
require 'rails_helper'

RSpec.describe "規格說明" do
  describe "處於某個狀態下" do
    # 設定狀態變數
    let(:a) { 1 }
    it "should be 1" do
      puts "should be 1"
      expect(a).to eq(1)
    end
  end
end
```

##Let

let 在每次測試裡，第一次存取變數時就會執行對應的程式

```ruby
require 'rails_helper'

RSpec.describe "規格說明" do
  describe "處於某個狀態下" do
    let(:a) { puts "let a"; 1  }
    it "1" do
      puts "1"
      puts "a=#{a}"
    end
     it "2" do
      puts "2"
      puts "a=#{a}"
      puts "a=#{a}"
      puts "a=#{a}"
    end
  end
end
```

輸出

```ruby
1
let a
a=1
.2
let a
a=1
a=1
a=1
.
```

## before & after

before 和 after 會在所有測試的執行前後做事

```ruby
RSpec.describe "規格說明" do
  describe "處於某個狀態下" do
    before { puts "before" }
    after { puts "after" }
    it "1" do
      puts "1"
    end
    it "2" do
      puts "2"
    end
  end
end
```

執行結果

```ruby
before
1
after
.before
2
after
.
```

## 執行測試
執行測試的指令是在 rails 專案目錄下的 bash 輸入以下指令：

```bash
# 執行所有測試
rspec

# 執行某個資料夾下的所有測試
rspec ./spec/models

# 執行某個檔案裡的所有測試
rspec ./spec/models/user_spec.rb

# 執行某個檔案裡的某個測試
rspec ./spec/models/user_spec.rb:8
```