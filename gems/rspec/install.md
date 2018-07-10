#安裝流程

在 Gemfile 的

```
group :development, :test do

end
```

區段中寫入：

```
gem 'rspec-rails'
```

然後回到 bash 下指令安裝 gem：

```
bundle
```

安裝好 rspec 之後，建立初始環境：

```
rails generate rspec:install
```

#測試安裝結果

新增一個 model 的同時會新增出 model 的測試檔。

```
rails g model aaa
```

使用 rspec 執行自動測試

```
rspec
```