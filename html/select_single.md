# 下拉式選單-單選

## HTML

下拉式選單通常用於單選或者多選，在頁面資訊較多時使用，因為他可以隱藏選項。

本篇講解單選的部分：

```html
<input type="checkbox" value="1" name="a" id="a1">
```

用戶點擊一下就選取，再點擊一下就變成未選取，多個按鈕是獨立運作的。

```html
<input type="checkbox" value="1" name="a" id="a1">
<input type="checkbox" value="2" name="a" id="a2">
<input type="checkbox" value="3" name="a" id="a3">
```
這樣就表示 3 個是非題。

# jQuery

假設 html 如下：

```html
<div class="check_a">
  <input type="checkbox" value="1" name="a" id="a1">
  <input type="checkbox" value="2" name="a" id="a2">
  <input type="checkbox" value="3" name="a" id="a3">
</div>
<div class="check_b">
  <input type="checkbox" value="1" name="b" id="b1">
  <input type="checkbox" value="2" name="b" id="b2">
  <input type="checkbox" value="3" name="b" id="b3">
</div>
```

獲得 a 選取的值

```js
var checked_values = $(".check_a input:checked").map(function(){
  return $(this).val()
}).toArray();
```

因為會捕捉到多個，所以在 each 裡面處理。

或是

```js
$("input[name=a]:checked").map(function(){
  return $(this).val()
}).toArray();
```

捕捉那些 name 值為 a 的 input，而且是被用戶選取的那個。

這可以分兩段來看，第一段是把整個 A 區塊的選項都包含在內，但是要避免捕捉到其他題目的選項。第二段是透過 `:checked` 來捕捉用戶選取的項目。

其中的 `.val()` 會傳回捕捉到的第一個元素的 value 值，所以我們放在 map 函數裡面。

# Rails

從一個新專案開始

```bash
rails new check_box_test
cd check_box_test

rails g scaffold post name
rails g model tag name
rails g model post_tag post:references tag:references
rails db:create
rails db:migrate
```

修改 `app/models/post.rb`

```
class Post < ApplicationRecord
  has_many :post_tags
  has_many :tags, through: :post_tags
end
```

修改 `app/models/tag.rb`

```
class Tag < ApplicationRecord
  has_many :post_tags
  has_many :posts, through: :post_tags
end
```

建立一個 post 和 tag 多對多的資料模型和基礎的 CRUD 頁面。

修改 db/seeds.rb 檔，新增一些資料

```ruby
Tag.find_or_create_by(name: '電影')
Tag.find_or_create_by(name: '美食')
Tag.find_or_create_by(name: '旅遊')
```

再執行以下指令

```
rails db:seed
rails server
```

開啟 `app/views/posts/_form.html.erb`

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

我們要讓 post 可以上多個標籤，只要加上這段 code。

```
<div class="field">
  <% Tag.all.each do |tag| %>
    <%= form.check_box :tag_ids, {multiple: true}, tag.id, false %>
    <%= form.label :tag_ids, tag.name, value: tag.id %>
  <% end %>
</div>
```

就完成了。他產生的對應 HTML 如下：

```
<div class="field">
  <input type="checkbox" value="1" name="post[tag_ids][]" id="post_tag_ids_1">
  <label for="post_tag_ids_1">電影</label>
  <input type="checkbox" value="2" name="post[tag_ids][]" id="post_tag_ids_2">
  <label for="post_tag_ids_2">美食</label>
  <input type="checkbox" value="3" name="post[tag_ids][]" id="post_tag_ids_3">
  <label for="post_tag_ids_3">旅遊</label>
</div>
```

不過還要改一下 `app/controllers/posts_controller.rb` 當中的 `post_params`

加上接受參數 tag_ids: []

```
def post_params
  params.require(:post).permit(:name, tag_ids: [])
end
```

要不然會存不起來哦