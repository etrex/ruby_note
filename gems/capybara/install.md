# 安裝

gemfile

```
group :development, :test do
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
end
```

# 使用 headless chrome
參考文件：https://drivy.engineering/running-capybara-headless-chrome/

你需要安裝 chrome 版本為 59 以上，還需要安裝 chrome driver

## 安裝 chrome driver

請直接使用這個 gem 來安裝 chrome driver：https://github.com/flavorjones/chromedriver-helper#updating-to-latest-chromedriver

```
gem 'chromedriver-helper'
```

請勿使用以下的安裝方法：

```
brew install chromedriver
```
如果你使用 brew 安裝 chromedriver，你會發現 brew 上已經沒有 chromedriver 了，他被移到 cask 裡面，所以你可能會使用以下的指令：

```
brew tap homebrew/cask
brew cask install chromedriver
```

但是這樣安裝好了之後卻不能正常運作，因為在 cask 中的 chromedriver 少做了一些事情。

## capybara 設定

在 spec/rails_helper.rb 中寫入以下程式碼：

```
Capybara.register_driver(:headless_chrome) do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w[headless disable-gpu] }
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end

Capybara.javascript_driver = :headless_chrome
```

其中，最後一行 `Capybara.javascript_driver = :headless_chrome` 代表所有需要 js 的測試都使用 headless_chrome 來跑。

在 rpsec 怎麼分辨哪些測試是需要 js 的測試呢？

在一段 describe 中加入 `js: true` 表示在這裡面的測試會使用到 js。

```
describe 'QQ', type: :feature, js: true do
  it '這裡是要用 js 的測試' do
    ...
  end
end
```