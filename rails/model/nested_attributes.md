# 想要在 a 的表單中同時編輯 a 底下的 b

## model

在 model 中使用 `accepts_nested_attributes_for`
```
class A < ActiveRecord::Base
  has_many :bs
  accepts_nested_attributes_for :bs
end
```

## view

在 view 中使用 `fields_for` 來創造第二層的 form

```
<%= form_for @a do |f| %>
  <%= f.text_field :field_in_a %>

  <%= f.fields_for :bs do |bf| %>
    <%= bf.text_field :field_in_b %>
  <% end %>

<% end %>
```
