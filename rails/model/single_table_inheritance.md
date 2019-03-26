# STI(Single Table Inheritance)

讓多個 Model 使用同一張表格的方法。

當多個 Model 行為不一致，但是資料格式一致時可以使用。

優點是可以使用一次同時對多個 Model 做查詢。


## Parent Model 的建立
```
rails g model parent_table_name type
```

## Child Model 的建立
```
rails g model child_table_name --parent parent_table_name
```


## 模型的切換
```

```