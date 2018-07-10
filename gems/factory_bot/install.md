#安裝流程

在 Gemfile 的

```
group :development, :test do

end
```

區段中寫入：

```
gem 'factory_bot_rails'
```

然後回到 bash 下指令安裝 gem：

```
bundle
```

安裝好 rspec 之後，建立初始環境：

```
rails generate rspec:install
```

# 測試安裝結果

對 model aaa 作出 factory bot 的檔案。

```
rails g factory_bot:model Aaa
```

在測試程式中寫入

```
aaa = FactoryBot.create(:aaa)
```

使用 rspec 執行自動測試

```
rspec
```

# 在測試檔案中省略 FactoryBot

修改 `spec_helper.rb`，加入 `require 'factory_bot_rails'` 以及 `config.include FactoryBot::Syntax::Methods` 在正確的位置。

```
...

require 'factory_bot_rails'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  ...
end
```

測試程式碼即可改為

```
aaa = create(:aaa)
```
