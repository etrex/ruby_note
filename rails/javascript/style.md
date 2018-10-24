# 在 Rails 應該要怎麼寫 JS

## 資料傳遞

有的時候我們會想要從 ruby 傳一些資料給 js 執行，最簡單的做法會是用 js.erb 或者直接在 view 上寫 js。

但是比較推薦的寫法會是將資料放在 html 結構上再由 js 去取，也就是透過 html 來保存資料。

透過 html 來傳遞資料，你的 js 才不會越寫越亂，也能夠做出更方便使用的前端功能。

推薦寫法的特點是，只要你按照這種寫法，你就可以將你的 js 移動到任何地方，都不會受到限制。

### 不良的寫法

js.erb 寫法或 view 寫法都能達到相同效果。

#### js.erb

```
var type = '<%= @data.type %>';
```

#### view

```
<script>
  var type = '<%= @data.type %>';
</script>
```

### 推薦的寫法

以下 view 程式碼必須搭配 js 服用。

#### view
```
<div data-type=<%= @data.type %>>
```

或者用 helper

```
<%= content_tag :div, id: 'data', data: @data %>
```

#### js

```
var type = $('#data').data('type');
```

使用 jQuery 的 data 方法取得 html 上的資料。


## 事件觸發

有的時候我們會想要在某些頁面載入時執行某段程式碼，這有很多種做法。

### 推薦的寫法

在頁面上的元素的 id 或 class 放置記號，然後在 js 端去做呼叫。

view
```
<div class="show_popup_when_click"> ... </div>
```

js

```
function show_popup(){
  ...
}
$('.show_popup_when_click').click(show_popup);
```