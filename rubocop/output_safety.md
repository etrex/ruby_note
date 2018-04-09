# 問題
string.html_safe 允許一個 string 顯示時不再進行 html_encode，因此可能會有安全性問題。

http://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Rails/OutputSafety

為了避免直接將 string 輸出，我們可以先對 string 做檢查後再輸出。

可以使用 rails 提供的各種檢查工具，組合出我們想要的內容。

# 使用 content_tag

https://apidock.com/rails/ActionView/Helpers/TagHelper/content_tag

```
content_tag(:p, user_content)
```
content_tag 會將 user_content 做 html_encode。

# 使用 concat

ActiveSupport::SafeBuffer 做 concat 時會將 user_content 做 html_encode。
```
out.safe_concat(user_content)
```

可以用來組合 ActiveSupport::SafeBuffer 和 String

# safe_join

```
out = []
out << content_tag(:li, user_content)
out << content_tag(:li, user_content)
safe_join(out)
```

使用 safe_join 來組合多個 ActiveSupport::SafeBuffer 和 String