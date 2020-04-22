https://railsguides.net/advanced-rails-model-generators/



# 在 generator 當中會用到的各種變數介紹

當 generator 繼承 `Rails::Generators::NamedBase` 時，你可以在 template 使用以下變數：

```
<%
mm = [
  :singular_name,
  :inside_template?,
  :file_path,
  :class_path,
  :regular_class_path,
  :class_name,
  :human_name,
  :plural_name,
  :table_name,
  :index_helper,
  :show_helper,
  :edit_helper,
  :new_helper,
  :singular_table_name,
  :plural_table_name,
  :plural_file_name,
  :fixture_file_name,
  :route_url,
  :url_helper_prefix,
  :application_name,
  :redirect_resource_name,
  :model_resource_name,
  :singular_route_name,
  :plural_route_name,
  :attributes_names,
  :pluralize_table_names?,
  :mountable_engine?,
]
-%>
<% mm.each do |m|-%>
  <%= m %>: <%= send(m) %>
<% end -%>
```

假設使用時 model 名稱為 todo, column 名稱為 name，會獲得以下結果：

```
  singular_name: todo
  inside_template?: true
  file_path: todo
  class_path: []
  regular_class_path: []
  class_name: Todo
  human_name: Todo
  plural_name: todos
  table_name: todos
  index_helper: todos
  show_helper: todo_url(@todo)
  edit_helper: edit_todo_url(@todo)
  new_helper: new_todo_url
  singular_table_name: todo
  plural_table_name: todos
  plural_file_name: todos
  fixture_file_name: todos
  route_url: /todos
  url_helper_prefix: todo
  application_name: kamigo_demo
  redirect_resource_name: @todo
  model_resource_name: todo
  singular_route_name: todo
  plural_route_name: todos
  attributes_names: [:id, "name"]
  pluralize_table_names?: true
  mountable_engine?:
```