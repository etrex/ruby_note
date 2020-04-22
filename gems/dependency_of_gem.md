# 我想要在一個 gem 當中使用另一個 gem 時該怎麼寫呢？

假設我們現在要做一個 gem 叫做 `gem_with_dependency`，而且我們想要在 gem 當中引用 `fake_chatbot`，我們需要在 .gemspec 檔案中加入一行 `spec.add_dependency`：

```
Gem::Specification.new do |spec|
  # 其他...

  spec.add_dependency "fake_chatbot"
end
```

如果你查到的文章是寫 `spec.add_runtime_dependency`，這個的效果會和 `spec.add_dependency` 完全相同。

在加上後，在 rails 當中引用這個 gem 時，就會自動安裝 fake_chatbot。

但是 rails 並不會自動幫你載入 fake_chatbot，你可以在 rails 當中需要使用 fake_chatbot 時寫 `require "fake_chatbot`。

# 我想要自動載入依賴的 gem

當我們在 rails 的 Gemfile 寫上 `gem "gem_with_dependency"` 之後，rails 會自動載入 `lib/gem_with_dependency.rb`，所以你也可以將 `require "fake_chatbot` 寫在你的 gem 當中的 `lib/gem_with_dependency.rb`：

```
require "gem_with_dependency/version"
require "fake_chatbot"

module GemWithDependency
  class Error < StandardError; end
  # Your code goes here...
end
```

這就是一個 gem 如何依賴另一個 gem。