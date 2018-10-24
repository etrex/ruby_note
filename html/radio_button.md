# 單選按鈕

## HTML

單選按鈕通常用於選擇題，讓用戶從多個選項當中選一個。

```html
<input type="radio" name="a" id="a1" value="a1">
```

當一個頁面上有多個相同 name 的單選按鈕時，瀏覽器會確保用戶只能選取其中一個選項。

```html
<input type="radio" name="a" id="a1" value="1">
<input type="radio" name="a" id="a2" value="2">
<input type="radio" name="a" id="a3" value="3">
```

這樣就表示 3 選 1。

# jQuery

假設 html 如下：

```html
<div class="radio_a">
  <input type="radio" name="a" id="a1" value="1">
  <input type="radio" name="a" id="a2" value="2">
  <input type="radio" name="a" id="a3" value="3">
</div>
<div class="radio_b">
  <input type="radio" name="b" id="b1" value="1">
  <input type="radio" name="b" id="b2" value="2">
  <input type="radio" name="b" id="b3" value="3">
</div>
```

獲得 a 選取的值

```js
$('.radio_a input:checked').val();
```

捕捉在 radio_a 當中的 input，而且是被用戶選取的那個。

或是

```js
$('input[name=a]:checked').val();
```

捕捉那些 name 值為 a 的 input，而且是被用戶選取的那個。

這可以分兩段來看，第一段是把整個選擇題的選項都包含在內，但是要避免捕捉到其他題目的選項。第二段是透過 `:checked` 來捕捉用戶選取的項目。

其中的 `.val()` 會傳回捕捉到的第一個元素的 value 值。

# Rails

從一個新專案開始

```bash
rails new radio_test
cd radio_test

rails g scaffold post name
rails db:create
rails db:migrate
rails server
```

建立一個 post 資料模型和基礎的 CRUD 頁面。

開啟其中的 `app/views/posts/_form.html.erb`

```erb
<%= form_with(model: post, local: true) do |form| %>
  <% if post.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(post.errors.count, "error") %> prohibited this post from being saved:</h2>

      <ul>
      <% post.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
      </ul>
    </div>
  <% end %>

  <div class="field">
    <%= form.label :name %>
    <%= form.text_field :name %>
  </div>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```

我們要將 name 欄位改為用單選按鈕來選擇。也就是修改這裡：

```
<div class="field">
  <%= form.label :name %>
  <%= form.text_field :name %>
</div>
```

改為

```
<div class="field">
  <%= form.label :name %>
  <%= form.radio_button :name, 'QQ' %>:QQ<br/>
  <%= form.radio_button :name, 'XD' %>:XD
</div>
```

就完成了。他產生的對應 HTML 如下：

```
<div class="field">
  <label for="post_name">Name</label>
  <input type="radio" value="QQ" name="post[name]" id="post_name_qq">:QQ<br>
  <input type="radio" value="XD" name="post[name]" id="post_name_xd">:XD
</div>
```